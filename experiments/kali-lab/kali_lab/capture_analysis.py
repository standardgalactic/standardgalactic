from __future__ import annotations

import csv
import json
import statistics
from collections import Counter, defaultdict
from pathlib import Path

from .capture_ingest import read_capture
from .capture_models import FlowSession, Observation, PacketEvent
from .capture_normalize import normalize_packets
from .flow_reconstruct import build_flows


def analyze_capture_file(path: str | Path) -> dict:
    records, parser_warnings = read_capture(path)
    events, _packet_observations = normalize_packets(records)
    flows, observations, flow_packet_map = build_flows(events)

    timing_entropy = _timing_entropy(events)
    size_entropy = _size_entropy(events)
    dns_relations = _dns_relations(events)
    tls_progression = _tls_progression(events)

    hosts = _host_summary(events)
    packet_to_flow = _packet_to_flow_map(flow_packet_map)
    timeline = _timeline(events, observations, packet_to_flow)
    clusters = _session_clusters(flows)
    observation_rows = _observation_rows(observations)
    protocol_counts = Counter(event.app_protocol for event in events)
    anomaly_score = _composite_anomaly_score(observations)

    return {
        "capture": {
            "capture_id": f"cap-{Path(path).name}",
            "source": str(path),
            "packet_count": len(events),
            "parser_warnings": parser_warnings,
            "timing_entropy": timing_entropy,
            "size_entropy": size_entropy,
            "protocol_counts": dict(protocol_counts),
            "composite_anomaly_score": anomaly_score,
        },
        "hosts": hosts,
        "flows": [_flow_to_dict(flow, flow_packet_map.get(flow.flow_id, [])) for flow in flows],
        "packets": [_packet_to_dict(event) for event in events],
        "timeline": timeline,
        "observations": observation_rows,
        "dns": dns_relations,
        "tls": tls_progression,
        "clusters": clusters,
    }


def compare_captures(paths: list[str | Path]) -> dict:
    analyses = [analyze_capture_file(path) for path in paths]
    if len(analyses) < 2:
        raise ValueError("compare requires at least two captures")

    protocol_vectors = {
        analysis["capture"]["source"]: analysis["capture"]["protocol_counts"] for analysis in analyses
    }
    flow_counts = {analysis["capture"]["source"]: len(analysis["flows"]) for analysis in analyses}
    timing_entropy = {analysis["capture"]["source"]: analysis["capture"]["timing_entropy"] for analysis in analyses}
    payload_entropy = {
        analysis["capture"]["source"]: _mean_payload_entropy(analysis["packets"]) for analysis in analyses
    }
    anomaly_families = {
        analysis["capture"]["source"]: Counter(obs["family"] for obs in analysis["observations"]) for analysis in analyses
    }

    return {
        "captures": [analysis["capture"]["source"] for analysis in analyses],
        "protocol_composition": protocol_vectors,
        "flow_counts": flow_counts,
        "timing_entropy": timing_entropy,
        "payload_entropy_mean": payload_entropy,
        "anomaly_families": {key: dict(value) for key, value in anomaly_families.items()},
    }


def summarize_analysis(analysis: dict) -> str:
    capture = analysis["capture"]
    protocols = capture["protocol_counts"]
    obs_counts = Counter(obs["family"] for obs in analysis["observations"])
    malformed = obs_counts.get("malformed_structure", 0)

    lines = [
        f"Capture notebook: {Path(capture['source']).name}",
        f"Evidence established: {capture['packet_count']} packets, {len(analysis['flows'])} bidirectional flows, protocols={protocols}.",
        f"Observed unusual evidence (not intent claims): {dict(obs_counts)}.",
        "Unusual does not imply hostile; high entropy may reflect compression or encryption and is treated as contextual evidence only.",
        "Inference limits: encrypted payload content, user intent, and endpoint compromise state cannot be determined from passive capture alone.",
    ]
    if malformed:
        lines.append(f"Structural parsing anomalies were present in {malformed} observation(s); affected frames were isolated without stopping analysis.")
    return "\n".join(lines)


def timeline_window(analysis: dict, start: float, end: float) -> list[dict]:
    return [event for event in analysis["timeline"] if start <= event.get("rel_time", 0.0) <= end]


def export_analysis_json(analysis: dict, path: str | Path) -> None:
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(analysis, indent=2, sort_keys=True), encoding="utf-8")


def export_flows_csv(analysis: dict, path: str | Path) -> None:
    fields = [
        "flow_id",
        "canonical_key",
        "transport",
        "app_protocol",
        "packet_total",
        "payload_total",
        "duration",
        "packets_ab",
        "packets_ba",
        "bytes_ab",
        "bytes_ba",
        "tcp_state",
        "reset_seen",
        "handshake_complete",
    ]
    rows = analysis.get("flows", [])
    _write_csv(path, fields, rows)


def export_timeline_csv(analysis: dict, path: str | Path) -> None:
    fields = ["event_id", "rel_time", "timestamp", "flow_id", "packet_id", "event", "details"]
    rows = analysis.get("timeline", [])
    _write_csv(path, fields, rows)


def export_observations_csv(analysis: dict, path: str | Path) -> None:
    fields = ["observation_id", "family", "flow_id", "packet_id", "evidence", "score_component"]
    rows = analysis.get("observations", [])
    _write_csv(path, fields, rows)


def _write_csv(path: str | Path, fields: list[str], rows: list[dict]) -> None:
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field) for field in fields})


def _packet_to_dict(event: PacketEvent) -> dict:
    return {
        "packet_id": event.packet_id,
        "index": event.index,
        "timestamp": event.timestamp,
        "rel_time": event.rel_time,
        "ip_src": event.ip_src,
        "ip_dst": event.ip_dst,
        "transport": event.transport,
        "src_port": event.src_port,
        "dst_port": event.dst_port,
        "app_protocol": event.app_protocol,
        "frame_length": event.frame_length,
        "payload_length": event.payload_length,
        "payload_entropy": event.payload_entropy,
        "size_class": event.size_class,
        "tcp_flags": event.tcp_flags,
        "metadata": event.metadata,
        "observations": [
            {
                "observation_id": obs.observation_id,
                "family": obs.family,
                "evidence": obs.evidence,
                "score_component": obs.score_component,
            }
            for obs in event.observations
        ],
    }


def _flow_to_dict(flow: FlowSession, packet_ids: list[str]) -> dict:
    return {
        "flow_id": flow.flow_id,
        "canonical_key": flow.canonical_key,
        "transport": flow.transport,
        "endpoint_a": flow.endpoint_a,
        "endpoint_b": flow.endpoint_b,
        "first_seen": flow.first_seen,
        "last_seen": flow.last_seen,
        "packet_total": flow.packet_total,
        "payload_total": flow.payload_total,
        "duration": flow.duration,
        "packets_ab": flow.packets_ab,
        "packets_ba": flow.packets_ba,
        "bytes_ab": flow.bytes_ab,
        "bytes_ba": flow.bytes_ba,
        "interarrival_avg": flow.interarrival_avg,
        "interarrival_min": flow.interarrival_min,
        "interarrival_max": flow.interarrival_max,
        "app_protocol": flow.app_protocol,
        "tcp_state": flow.tcp_state,
        "reset_seen": flow.reset_seen,
        "fin_seen": flow.fin_seen,
        "handshake_complete": flow.handshake_complete,
        "feature_vector": flow.feature_vector,
        "packet_ids": packet_ids,
    }


def _host_summary(events: list[PacketEvent]) -> list[dict]:
    hosts: dict[str, dict] = defaultdict(lambda: {"host": "", "sent_packets": 0, "recv_packets": 0, "sent_bytes": 0, "recv_bytes": 0})
    for event in events:
        if event.ip_src:
            row = hosts[event.ip_src]
            row["host"] = event.ip_src
            row["sent_packets"] += 1
            row["sent_bytes"] += event.payload_length
        if event.ip_dst:
            row = hosts[event.ip_dst]
            row["host"] = event.ip_dst
            row["recv_packets"] += 1
            row["recv_bytes"] += event.payload_length
    return sorted(hosts.values(), key=lambda row: row["host"])


def _timeline(events: list[PacketEvent], observations: list[Observation], packet_to_flow: dict[str, str]) -> list[dict]:
    obs_by_packet: dict[str, list[Observation]] = defaultdict(list)
    for obs in observations:
        if obs.packet_id:
            obs_by_packet[obs.packet_id].append(obs)

    lines: list[dict] = []
    for idx, event in enumerate(sorted(events, key=lambda item: item.timestamp), start=1):
        detail = {
            "transport": event.transport,
            "src": event.ip_src,
            "dst": event.ip_dst,
            "src_port": event.src_port,
            "dst_port": event.dst_port,
            "protocol": event.app_protocol,
        }
        if event.metadata:
            detail["metadata"] = event.metadata
        if event.packet_id in obs_by_packet:
            detail["observations"] = [obs.evidence for obs in obs_by_packet[event.packet_id]]

        lines.append(
            {
                "event_id": f"evt-{idx:05d}",
                "packet_id": event.packet_id,
                "flow_id": packet_to_flow.get(event.packet_id),
                "timestamp": event.timestamp,
                "rel_time": event.rel_time,
                "event": event.app_protocol,
                "details": json.dumps(detail, sort_keys=True),
            }
        )

    return lines


def _observation_rows(observations: list[Observation]) -> list[dict]:
    return [
        {
            "observation_id": obs.observation_id,
            "packet_id": obs.packet_id,
            "flow_id": obs.flow_id,
            "family": obs.family,
            "evidence": obs.evidence,
            "score_component": obs.score_component,
        }
        for obs in observations
    ]


def _packet_to_flow_map(flow_packet_map: dict[str, list[str]]) -> dict[str, str]:
    mapping: dict[str, str] = {}
    for flow_id, packet_ids in flow_packet_map.items():
        for packet_id in packet_ids:
            mapping[packet_id] = flow_id
    return mapping


def _timing_entropy(events: list[PacketEvent]) -> float:
    if len(events) < 3:
        return 0.0
    sorted_events = sorted(events, key=lambda event: event.timestamp)
    gaps = [sorted_events[i].timestamp - sorted_events[i - 1].timestamp for i in range(1, len(sorted_events))]
    return _distribution_entropy(gaps)


def _size_entropy(events: list[PacketEvent]) -> float:
    sizes = [event.frame_length for event in events]
    return _distribution_entropy(sizes)


def _distribution_entropy(values: list[float]) -> float:
    if not values:
        return 0.0
    rounded = [round(value, 3) for value in values]
    counts = Counter(rounded)
    total = len(rounded)
    entropy = 0.0
    for count in counts.values():
        p = count / total
        entropy -= p * (0 if p == 0 else math_log2(p))
    return entropy


def math_log2(value: float) -> float:
    import math

    return math.log2(value)


def _dns_relations(events: list[PacketEvent]) -> list[dict]:
    queries: dict[tuple[str, str, str], PacketEvent] = {}
    relations: list[dict] = []

    for event in sorted(events, key=lambda item: item.timestamp):
        if event.app_protocol != "DNS":
            continue
        txid = event.metadata.get("dns_txid")
        qr = event.metadata.get("dns_qr")
        qname = event.metadata.get("dns_qname", "")
        key = (txid or "", qname, event.metadata.get("dns_qtype", ""))

        if qr == "0":
            queries[key] = event
        elif qr == "1":
            query = queries.get(key)
            relations.append(
                {
                    "txid": txid,
                    "qname": qname,
                    "qtype": event.metadata.get("dns_qtype"),
                    "rcode": event.metadata.get("dns_rcode"),
                    "answer_count": event.metadata.get("dns_ancount"),
                    "query_packet_id": query.packet_id if query else None,
                    "response_packet_id": event.packet_id,
                    "response_delay": (event.timestamp - query.timestamp) if query else None,
                }
            )

    return relations


def _tls_progression(events: list[PacketEvent]) -> list[dict]:
    rows: list[dict] = []
    for event in events:
        if event.app_protocol != "TLS":
            continue
        rows.append(
            {
                "packet_id": event.packet_id,
                "version": event.metadata.get("tls_version"),
                "record_type": event.metadata.get("tls_record_type"),
                "handshake_type": event.metadata.get("tls_handshake_type"),
                "handshake_label": event.metadata.get("tls_handshake_label"),
                "sni": event.metadata.get("tls_sni"),
                "alpn": event.metadata.get("tls_alpn"),
            }
        )
    return rows


def _session_clusters(flows: list[FlowSession]) -> list[dict]:
    buckets: dict[str, list[str]] = defaultdict(list)
    for flow in flows:
        feature = flow.feature_vector
        duration_band = "long" if feature.get("duration", 0.0) > 1.0 else "short"
        ratio_band = "egress-heavy" if feature.get("ratio_ab_to_ba", 1.0) > 2 else "balanced"
        entropy_band = "high-entropy" if feature.get("entropy_avg", 0.0) > 5 else "normal-entropy"
        key = f"{flow.app_protocol}|{duration_band}|{ratio_band}|{entropy_band}"
        buckets[key].append(flow.flow_id)

    clusters = []
    for idx, (key, flow_ids) in enumerate(sorted(buckets.items()), start=1):
        clusters.append(
            {
                "cluster_id": f"cluster-{idx:03d}",
                "feature_signature": key,
                "flow_count": len(flow_ids),
                "flow_ids": flow_ids,
            }
        )
    return clusters


def _mean_payload_entropy(packets: list[dict]) -> float:
    values = [packet.get("payload_entropy", 0.0) for packet in packets]
    return statistics.fmean(values) if values else 0.0


def _composite_anomaly_score(observations: list[Observation]) -> dict:
    families = defaultdict(float)
    for obs in observations:
        families[obs.family] += obs.score_component
    total = sum(families.values())
    return {"total": total, "components": dict(families)}
