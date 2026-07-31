from __future__ import annotations

import math
from collections import Counter

from .capture_models import Observation, PacketEvent, PacketRecord


def _entropy(payload: bytes) -> float:
    if not payload:
        return 0.0
    counts = Counter(payload)
    total = len(payload)
    acc = 0.0
    for count in counts.values():
        p = count / total
        acc -= p * math.log2(p)
    return acc


def normalize_packets(records: list[PacketRecord]) -> tuple[list[PacketEvent], list[Observation]]:
    if not records:
        return [], []

    baseline = min(record.timestamp for record in records)
    events: list[PacketEvent] = []
    observations: list[Observation] = []

    for record in records:
        event = _decode_event(record, baseline)
        events.append(event)
        observations.extend(event.observations)

    return events, observations


def _decode_event(record: PacketRecord, baseline: float) -> PacketEvent:
    packet_id = f"pkt-{record.index:05d}"
    event = PacketEvent(
        packet_id=packet_id,
        index=record.index,
        timestamp=record.timestamp,
        rel_time=record.timestamp - baseline,
        frame_length=record.captured_length,
        payload_length=0,
        ip_src=None,
        ip_dst=None,
        transport="UNKNOWN",
        src_port=None,
        dst_port=None,
        direction_key=None,
        app_protocol="UNKNOWN",
        payload_entropy=0.0,
        size_class=_size_class(record.captured_length),
        metadata={"source": record.source},
    )

    for warning in record.parse_warnings:
        event.observations.append(
            Observation(
                observation_id=f"obs-{packet_id}-{len(event.observations)}",
                packet_id=packet_id,
                flow_id=None,
                family="malformed_structure",
                evidence=warning,
                score_component=1.0,
            )
        )

    frame = record.data
    if len(frame) < 14:
        _add_observation(event, "malformed_structure", "truncated_ethernet", 2.0)
        return event

    ethertype = int.from_bytes(frame[12:14], "big")
    if ethertype != 0x0800:
        event.metadata["ethertype"] = f"0x{ethertype:04x}"
        return event

    ip = frame[14:]
    if len(ip) < 20:
        _add_observation(event, "malformed_structure", "truncated_ipv4", 2.0)
        return event

    version = ip[0] >> 4
    ihl = (ip[0] & 0x0F) * 4
    if version != 4:
        _add_observation(event, "malformed_structure", "non_ipv4_version", 1.0)
        return event
    if ihl < 20 or len(ip) < ihl:
        _add_observation(event, "malformed_structure", "invalid_ipv4_header_length", 2.0)
        return event

    total_len = int.from_bytes(ip[2:4], "big")
    if total_len < ihl:
        _add_observation(event, "malformed_structure", "invalid_ipv4_total_length", 2.0)
        return event

    ip_payload_end = min(len(ip), total_len)
    event.ip_src = ".".join(str(n) for n in ip[12:16])
    event.ip_dst = ".".join(str(n) for n in ip[16:20])
    proto = ip[9]
    l4 = ip[ihl:ip_payload_end]

    if proto == 6:
        event.transport = "TCP"
        if len(l4) < 20:
            _add_observation(event, "malformed_structure", "truncated_tcp", 2.0)
            return event
        event.src_port = int.from_bytes(l4[0:2], "big")
        event.dst_port = int.from_bytes(l4[2:4], "big")
        doff = ((l4[12] >> 4) & 0xF) * 4
        flags = l4[13]
        event.tcp_flags = _decode_tcp_flags(flags)
        if doff < 20 or len(l4) < doff:
            _add_observation(event, "malformed_structure", "invalid_tcp_header_length", 2.0)
            return event
        payload = l4[doff:]
    elif proto == 17:
        event.transport = "UDP"
        if len(l4) < 8:
            _add_observation(event, "malformed_structure", "truncated_udp", 2.0)
            return event
        event.src_port = int.from_bytes(l4[0:2], "big")
        event.dst_port = int.from_bytes(l4[2:4], "big")
        udp_len = int.from_bytes(l4[4:6], "big")
        if udp_len < 8 or len(l4) < udp_len:
            _add_observation(event, "malformed_structure", "invalid_udp_length", 2.0)
            return event
        payload = l4[8:udp_len]
    else:
        event.transport = f"IP-{proto}"
        payload = l4

    event.payload_length = len(payload)
    event.payload_entropy = _entropy(payload)
    event.app_protocol = _identify_protocol(event, payload)
    return event


def _identify_protocol(event: PacketEvent, payload: bytes) -> str:
    sport = event.src_port or 0
    dport = event.dst_port or 0
    if event.transport == "UDP" and (sport == 53 or dport == 53):
        _extract_dns(event, payload)
        return "DNS"

    if event.transport == "TCP":
        if sport in {80, 8080} or dport in {80, 8080} or payload.startswith((b"GET ", b"POST ", b"HEAD ", b"HTTP/")):
            _extract_http(event, payload)
            return "HTTP"
        if sport == 443 or dport == 443 or (len(payload) >= 3 and payload[0] == 0x16 and payload[1] == 0x03):
            _extract_tls(event, payload)
            return "TLS"

    return "UNKNOWN"


def _extract_dns(event: PacketEvent, payload: bytes) -> None:
    if len(payload) < 12:
        _add_observation(event, "malformed_structure", "dns_header_too_short", 1.0)
        return

    txid = int.from_bytes(payload[0:2], "big")
    flags = int.from_bytes(payload[2:4], "big")
    qr = (flags >> 15) & 1
    rcode = flags & 0xF
    qd = int.from_bytes(payload[4:6], "big")
    an = int.from_bytes(payload[6:8], "big")

    event.metadata.update(
        {
            "dns_txid": str(txid),
            "dns_qr": str(qr),
            "dns_rcode": str(rcode),
            "dns_qdcount": str(qd),
            "dns_ancount": str(an),
        }
    )

    if qd > 0:
        cursor = 12
        labels: list[str] = []
        while cursor < len(payload):
            ln = payload[cursor]
            cursor += 1
            if ln == 0:
                break
            if cursor + ln > len(payload):
                _add_observation(event, "malformed_structure", "dns_label_out_of_bounds", 1.0)
                break
            labels.append(payload[cursor : cursor + ln].decode("ascii", "ignore"))
            cursor += ln
        if labels:
            event.metadata["dns_qname"] = ".".join(labels)
        if cursor + 4 <= len(payload):
            qtype = int.from_bytes(payload[cursor : cursor + 2], "big")
            event.metadata["dns_qtype"] = str(qtype)


def _extract_http(event: PacketEvent, payload: bytes) -> None:
    text = payload.decode("latin-1", "ignore")
    if "\r\n" in text:
        first = text.split("\r\n", 1)[0]
    else:
        first = text.strip()
    if first:
        event.metadata["http_first_line"] = first
        parts = first.split()
        if first.startswith("HTTP/") and len(parts) >= 2:
            event.metadata["http_status"] = parts[1]
        elif len(parts) >= 2:
            event.metadata["http_method"] = parts[0]
            event.metadata["http_path"] = parts[1]

    for line in text.split("\r\n"):
        if line.lower().startswith("host:"):
            event.metadata["http_host"] = line.split(":", 1)[1].strip()
        if line.lower().startswith("content-type:"):
            event.metadata["http_content_type"] = line.split(":", 1)[1].strip()


def _extract_tls(event: PacketEvent, payload: bytes) -> None:
    if len(payload) < 5:
        _add_observation(event, "malformed_structure", "tls_header_too_short", 1.0)
        return

    content_type = payload[0]
    version = f"0x{payload[1]:02x}{payload[2]:02x}"
    event.metadata["tls_record_type"] = str(content_type)
    event.metadata["tls_version"] = version

    if content_type == 22 and len(payload) >= 6:
        handshake_type = payload[5]
        event.metadata["tls_handshake_type"] = str(handshake_type)
        if handshake_type == 1:
            event.metadata["tls_handshake_label"] = "client_hello"
            _extract_tls_client_hello_extensions(event, payload)
        elif handshake_type == 2:
            event.metadata["tls_handshake_label"] = "server_hello"


def _extract_tls_client_hello_extensions(event: PacketEvent, payload: bytes) -> None:
    # Best-effort parser for exposed SNI/ALPN; failures become observations, not crashes.
    try:
        if len(payload) < 50:
            return
        rec_len = int.from_bytes(payload[3:5], "big")
        if 5 + rec_len > len(payload):
            _add_observation(event, "malformed_structure", "truncated_tls_record", 1.0)
            return
        hs_len = int.from_bytes(payload[6:9], "big")
        body_start = 9
        body_end = min(len(payload), body_start + hs_len)
        body = payload[body_start:body_end]
        if len(body) < 34:
            return
        cursor = 34
        sess_len = body[cursor]
        cursor += 1 + sess_len
        if cursor + 2 > len(body):
            return
        cs_len = int.from_bytes(body[cursor : cursor + 2], "big")
        cursor += 2 + cs_len
        if cursor >= len(body):
            return
        comp_len = body[cursor]
        cursor += 1 + comp_len
        if cursor + 2 > len(body):
            return
        ext_len = int.from_bytes(body[cursor : cursor + 2], "big")
        cursor += 2
        ext_end = min(len(body), cursor + ext_len)

        while cursor + 4 <= ext_end:
            ext_type = int.from_bytes(body[cursor : cursor + 2], "big")
            ext_size = int.from_bytes(body[cursor + 2 : cursor + 4], "big")
            cursor += 4
            ext_payload = body[cursor : cursor + ext_size]
            cursor += ext_size

            if ext_type == 0 and len(ext_payload) >= 5:
                name_len = int.from_bytes(ext_payload[3:5], "big")
                if 5 + name_len <= len(ext_payload):
                    event.metadata["tls_sni"] = ext_payload[5 : 5 + name_len].decode("ascii", "ignore")
            elif ext_type == 16 and len(ext_payload) >= 3:
                proto_len = ext_payload[2]
                if 3 + proto_len <= len(ext_payload):
                    event.metadata["tls_alpn"] = ext_payload[3 : 3 + proto_len].decode("ascii", "ignore")

    except Exception:
        _add_observation(event, "malformed_structure", "tls_extension_parse_failure", 0.5)


def _decode_tcp_flags(flags: int) -> list[str]:
    names = [(0x01, "FIN"), (0x02, "SYN"), (0x04, "RST"), (0x08, "PSH"), (0x10, "ACK"), (0x20, "URG")]
    return [name for mask, name in names if flags & mask]


def _size_class(size: int) -> str:
    if size < 80:
        return "small"
    if size < 400:
        return "medium"
    return "large"


def _add_observation(event: PacketEvent, family: str, evidence: str, score: float) -> None:
    event.observations.append(
        Observation(
            observation_id=f"obs-{event.packet_id}-{len(event.observations)}",
            packet_id=event.packet_id,
            flow_id=None,
            family=family,
            evidence=evidence,
            score_component=score,
        )
    )
