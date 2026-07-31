from __future__ import annotations

import statistics
from collections import defaultdict

try:
    import numpy as np
except ModuleNotFoundError:  # pragma: no cover
    np = None

from .capture_models import FlowSession, Observation, PacketEvent


def build_flows(events: list[PacketEvent]) -> tuple[list[FlowSession], list[Observation], dict[str, list[str]]]:
    grouped: dict[str, list[PacketEvent]] = defaultdict(list)
    for event in events:
        key = _canonical_flow_key(event)
        event.direction_key = _direction_key(event, key)
        grouped[key].append(event)

    flows: list[FlowSession] = []
    observations: list[Observation] = []
    flow_to_packets: dict[str, list[str]] = {}

    for idx, (key, packets) in enumerate(sorted(grouped.items()), start=1):
        packets.sort(key=lambda packet: packet.timestamp)
        flow_id = f"flow-{idx:04d}"
        flow_to_packets[flow_id] = [packet.packet_id for packet in packets]

        first = packets[0].timestamp
        last = packets[-1].timestamp
        duration = last - first if len(packets) > 1 else 0.0
        payload_total = sum(packet.payload_length for packet in packets)

        ab_packets = [packet for packet in packets if packet.direction_key == "A_TO_B"]
        ba_packets = [packet for packet in packets if packet.direction_key == "B_TO_A"]

        gaps = [packets[i].timestamp - packets[i - 1].timestamp for i in range(1, len(packets))] if len(packets) > 1 else [0.0]
        interarrival_avg = float(statistics.fmean(gaps)) if gaps else 0.0
        interarrival_min = float(min(gaps)) if gaps else 0.0
        interarrival_max = float(max(gaps)) if gaps else 0.0

        app_counts = defaultdict(int)
        for packet in packets:
            app_counts[packet.app_protocol] += 1
            for obs in packet.observations:
                obs.flow_id = flow_id
                observations.append(obs)

        dominant_app = max(app_counts.items(), key=lambda item: item[1])[0] if app_counts else "UNKNOWN"

        reset_seen = any("RST" in packet.tcp_flags for packet in packets)
        fin_seen = any("FIN" in packet.tcp_flags for packet in packets)
        syn_seen = any("SYN" in packet.tcp_flags for packet in packets)
        syn_ack_seen = any(set(["SYN", "ACK"]).issubset(set(packet.tcp_flags)) for packet in packets)
        ack_seen = any("ACK" in packet.tcp_flags for packet in packets)
        handshake_complete = syn_seen and syn_ack_seen and ack_seen

        tcp_state = "NOT_TCP"
        if packets[0].transport == "TCP":
            if reset_seen:
                tcp_state = "RESET"
            elif fin_seen:
                tcp_state = "FINISHED"
            elif handshake_complete:
                tcp_state = "ESTABLISHED"
            elif syn_seen:
                tcp_state = "INCOMPLETE_HANDSHAKE"
            else:
                tcp_state = "UNKNOWN_TCP_STATE"

        feature_vector = {
            "duration": duration,
            "packet_count": float(len(packets)),
            "payload_bytes": float(payload_total),
            "bytes_ab": float(sum(packet.payload_length for packet in ab_packets)),
            "bytes_ba": float(sum(packet.payload_length for packet in ba_packets)),
            "ratio_ab_to_ba": float((sum(packet.payload_length for packet in ab_packets) + 1.0) / (sum(packet.payload_length for packet in ba_packets) + 1.0)),
            "interarrival_avg": interarrival_avg,
            "interarrival_max": interarrival_max,
            "entropy_avg": float(statistics.fmean([packet.payload_entropy for packet in packets])) if packets else 0.0,
            "tcp_handshake_complete": 1.0 if handshake_complete else 0.0,
            "tcp_reset_seen": 1.0 if reset_seen else 0.0,
        }

        endpoint_a, endpoint_b = _extract_endpoints(key)
        flow = FlowSession(
            flow_id=flow_id,
            canonical_key=key,
            transport=packets[0].transport,
            endpoint_a=endpoint_a,
            endpoint_b=endpoint_b,
            first_seen=first,
            last_seen=last,
            packet_total=len(packets),
            payload_total=payload_total,
            duration=duration,
            packets_ab=len(ab_packets),
            packets_ba=len(ba_packets),
            bytes_ab=sum(packet.payload_length for packet in ab_packets),
            bytes_ba=sum(packet.payload_length for packet in ba_packets),
            interarrival_avg=interarrival_avg,
            interarrival_min=interarrival_min,
            interarrival_max=interarrival_max,
            app_protocol=dominant_app,
            tcp_state=tcp_state,
            reset_seen=reset_seen,
            fin_seen=fin_seen,
            handshake_complete=handshake_complete,
            feature_vector=feature_vector,
        )
        flows.append(flow)

        if packets[0].transport == "TCP" and syn_seen and not handshake_complete:
            observations.append(
                Observation(
                    observation_id=f"obs-{flow_id}-incomplete",
                    packet_id=packets[0].packet_id,
                    flow_id=flow_id,
                    family="incomplete_conversation",
                    evidence="tcp_handshake_not_completed",
                    score_component=1.5,
                )
            )
        if packets[0].transport == "TCP" and reset_seen:
            observations.append(
                Observation(
                    observation_id=f"obs-{flow_id}-reset",
                    packet_id=packets[0].packet_id,
                    flow_id=flow_id,
                    family="unexpected_state_transition",
                    evidence="tcp_reset_observed",
                    score_component=1.2,
                )
            )

    _attach_statistical_observations(flows, observations)
    _attach_rare_protocol_observations(flows, observations)
    _standardize_vectors(flows)
    return flows, observations, flow_to_packets


def _canonical_flow_key(event: PacketEvent) -> str:
    if event.ip_src is None or event.ip_dst is None:
        return f"MALFORMED|{event.index}"

    left = (event.ip_src, event.src_port or 0)
    right = (event.ip_dst, event.dst_port or 0)
    a, b = sorted([left, right], key=lambda item: (item[0], item[1]))
    return f"{event.transport}|{a[0]}:{a[1]}|{b[0]}:{b[1]}"


def _direction_key(event: PacketEvent, canonical_key: str) -> str | None:
    if "|" not in canonical_key or event.ip_src is None or event.src_port is None:
        return None
    _, endpoint_a, _ = canonical_key.split("|", 2)
    src_repr = f"{event.ip_src}:{event.src_port}"
    return "A_TO_B" if src_repr == endpoint_a else "B_TO_A"


def _extract_endpoints(canonical_key: str) -> tuple[str, str]:
    parts = canonical_key.split("|")
    if len(parts) < 3:
        return ("unknown", "unknown")
    return parts[1], parts[2]


def _attach_statistical_observations(flows: list[FlowSession], observations: list[Observation]) -> None:
    if len(flows) < 3:
        return

    durations = [flow.duration for flow in flows]
    entropies = [flow.feature_vector.get("entropy_avg", 0.0) for flow in flows]
    packet_counts = [float(flow.packet_total) for flow in flows]

    duration_threshold = _mean(durations) + 1.5 * _stddev(durations)
    entropy_threshold = _mean(entropies) + 1.5 * _stddev(entropies)
    packet_threshold = _mean(packet_counts) + 1.5 * _stddev(packet_counts)

    for flow in flows:
        if flow.duration > duration_threshold:
            observations.append(
                Observation(
                    observation_id=f"obs-{flow.flow_id}-timing",
                    packet_id=None,
                    flow_id=flow.flow_id,
                    family="unusual_timing",
                    evidence=f"duration_above_threshold:{flow.duration:.6f}",
                    score_component=0.7,
                )
            )
        if flow.feature_vector.get("entropy_avg", 0.0) > entropy_threshold:
            observations.append(
                Observation(
                    observation_id=f"obs-{flow.flow_id}-entropy",
                    packet_id=None,
                    flow_id=flow.flow_id,
                    family="unusual_entropy",
                    evidence="high_payload_entropy_with_context_required",
                    score_component=0.5,
                )
            )
        if flow.packet_total > packet_threshold:
            observations.append(
                Observation(
                    observation_id=f"obs-{flow.flow_id}-outlier",
                    packet_id=None,
                    flow_id=flow.flow_id,
                    family="statistical_outlier",
                    evidence=f"packet_count_outlier:{flow.packet_total}",
                    score_component=0.6,
                )
            )


def _attach_rare_protocol_observations(flows: list[FlowSession], observations: list[Observation]) -> None:
    combos = defaultdict(int)
    for flow in flows:
        combos[(flow.transport, flow.app_protocol)] += 1

    for flow in flows:
        if combos[(flow.transport, flow.app_protocol)] == 1 and flow.app_protocol not in {"HTTP", "DNS", "TLS"}:
            observations.append(
                Observation(
                    observation_id=f"obs-{flow.flow_id}-rare",
                    packet_id=None,
                    flow_id=flow.flow_id,
                    family="rare_protocol_port",
                    evidence=f"rare_combo:{flow.transport}:{flow.app_protocol}",
                    score_component=0.4,
                )
            )


def _standardize_vectors(flows: list[FlowSession]) -> None:
    if not flows:
        return

    keys = sorted(flows[0].feature_vector.keys())
    if np is not None:
        matrix = np.array([[flow.feature_vector.get(key, 0.0) for key in keys] for flow in flows], dtype=float)
        means = matrix.mean(axis=0)
        stds = matrix.std(axis=0)
        stds = np.where(stds == 0, 1.0, stds)
        standardized = (matrix - means) / stds
        for row_idx, flow in enumerate(flows):
            for col_idx, key in enumerate(keys):
                flow.feature_vector[f"z_{key}"] = float(standardized[row_idx, col_idx])
        return

    for key in keys:
        values = [flow.feature_vector.get(key, 0.0) for flow in flows]
        mean = _mean(values)
        std = _stddev(values) or 1.0
        for flow in flows:
            flow.feature_vector[f"z_{key}"] = float((flow.feature_vector.get(key, 0.0) - mean) / std)


def _mean(values: list[float]) -> float:
    return sum(values) / len(values) if values else 0.0


def _stddev(values: list[float]) -> float:
    if not values:
        return 0.0
    mean = _mean(values)
    variance = sum((value - mean) ** 2 for value in values) / len(values)
    return variance ** 0.5
