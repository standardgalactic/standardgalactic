from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Observation:
    observation_id: str
    packet_id: str | None
    flow_id: str | None
    family: str
    evidence: str
    score_component: float = 0.0


@dataclass
class PacketRecord:
    index: int
    timestamp: float
    captured_length: int
    original_length: int
    data: bytes
    source: str
    parse_warnings: list[str] = field(default_factory=list)


@dataclass
class PacketEvent:
    packet_id: str
    index: int
    timestamp: float
    rel_time: float
    frame_length: int
    payload_length: int
    ip_src: str | None
    ip_dst: str | None
    transport: str
    src_port: int | None
    dst_port: int | None
    direction_key: str | None
    app_protocol: str
    payload_entropy: float
    size_class: str
    tcp_flags: list[str] = field(default_factory=list)
    metadata: dict[str, str] = field(default_factory=dict)
    observations: list[Observation] = field(default_factory=list)


@dataclass
class FlowSession:
    flow_id: str
    canonical_key: str
    transport: str
    endpoint_a: str
    endpoint_b: str
    first_seen: float
    last_seen: float
    packet_total: int
    payload_total: int
    duration: float
    packets_ab: int
    packets_ba: int
    bytes_ab: int
    bytes_ba: int
    interarrival_avg: float
    interarrival_min: float
    interarrival_max: float
    app_protocol: str
    tcp_state: str
    reset_seen: bool
    fin_seen: bool
    handshake_complete: bool
    feature_vector: dict[str, float]
