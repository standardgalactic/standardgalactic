from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, List

from .transport_adapters import TransportAdapter

class PacketType(str, Enum):
    COMMAND = "COMMAND"
    STDIN = "STDIN"
    STDOUT = "STDOUT"
    STDERR = "STDERR"
    CONTROL = "CONTROL"
    FILE = "FILE"
    SIGNAL = "SIGNAL"
    HEARTBEAT = "HEARTBEAT"
    WINDOW = "WINDOW"
    REPLAY = "REPLAY"


@dataclass
class FabricPacket:
    session_id: int
    channel_id: int
    packet_type: PacketType
    seq: int
    timestamp: float
    flags: list[str]
    payload: str
    authenticated: bool = True


@dataclass
class ChannelState:
    channel_id: int
    name: str
    packets: List[FabricPacket] = field(default_factory=list)


@dataclass
class FabricSession:
    session_id: int
    channels: Dict[int, ChannelState] = field(default_factory=dict)

    def ensure_channel(self, channel_id: int, name: str) -> ChannelState:
        if channel_id not in self.channels:
            self.channels[channel_id] = ChannelState(channel_id=channel_id, name=name)
        return self.channels[channel_id]


class SessionFabric:
    """Offline simulation of a typed-packet persistent terminal fabric."""

    def __init__(self) -> None:
        self.sessions: Dict[int, FabricSession] = {}
        self.adapter: TransportAdapter | None = None

    def bind_transport(self, adapter: TransportAdapter) -> None:
        self.adapter = adapter

    def open_session(self, session_id: int) -> FabricSession:
        if session_id not in self.sessions:
            self.sessions[session_id] = FabricSession(session_id=session_id)
        return self.sessions[session_id]

    def route_packet(self, packet: FabricPacket, channel_name: str) -> None:
        session = self.open_session(packet.session_id)
        channel = session.ensure_channel(packet.channel_id, channel_name)
        channel.packets.append(packet)
        channel.packets.sort(key=lambda item: item.seq)
        if self.adapter is not None:
            self.adapter.send(_encode_packet(packet, channel_name))

    def ingest_transport(self) -> int:
        """Ingest any available transport envelopes into logical sessions."""

        if self.adapter is None:
            return 0
        consumed = 0
        while True:
            envelope = self.adapter.receive()
            if envelope is None:
                break
            packet, channel_name = _decode_packet(envelope)
            session = self.open_session(packet.session_id)
            channel = session.ensure_channel(packet.channel_id, channel_name)
            if all(existing.seq != packet.seq for existing in channel.packets):
                channel.packets.append(packet)
                channel.packets.sort(key=lambda item: item.seq)
            consumed += 1
        return consumed

    def attach_replay(self, session_id: int, last_seen: dict[int, int]) -> list[FabricPacket]:
        """Return missing packets per channel for reconnect workflows."""

        session = self.sessions.get(session_id)
        if session is None:
            return []

        replay: list[FabricPacket] = []
        for channel_id, channel in session.channels.items():
            threshold = last_seen.get(channel_id, -1)
            replay.extend(packet for packet in channel.packets if packet.seq > threshold)

        replay.sort(key=lambda packet: (packet.timestamp, packet.channel_id, packet.seq))
        return replay

    def prioritized_packets(self, session_id: int) -> list[FabricPacket]:
        """Prioritize latency-sensitive types over bulk payloads."""

        priorities = {
            PacketType.SIGNAL: 0,
            PacketType.CONTROL: 1,
            PacketType.STDIN: 2,
            PacketType.WINDOW: 3,
            PacketType.STDOUT: 4,
            PacketType.STDERR: 5,
            PacketType.HEARTBEAT: 6,
            PacketType.COMMAND: 7,
            PacketType.REPLAY: 8,
            PacketType.FILE: 9,
        }
        session = self.sessions.get(session_id)
        if session is None:
            return []

        packets = [packet for channel in session.channels.values() for packet in channel.packets]
        packets.sort(key=lambda packet: (priorities.get(packet.packet_type, 99), packet.timestamp, packet.seq))
        return packets


def _encode_packet(packet: FabricPacket, channel_name: str) -> bytes:
    fields = [
        str(packet.session_id),
        str(packet.channel_id),
        packet.packet_type.value,
        str(packet.seq),
        f"{packet.timestamp:.9f}",
        ",".join(packet.flags),
        "1" if packet.authenticated else "0",
        channel_name,
        packet.payload.replace("|", "\\u007c"),
    ]
    return "|".join(fields).encode("utf-8")


def _decode_packet(envelope: bytes) -> tuple[FabricPacket, str]:
    raw = envelope.decode("utf-8")
    session_id, channel_id, kind, seq, timestamp, flags, auth, channel_name, payload = raw.split("|", 8)
    packet = FabricPacket(
        session_id=int(session_id),
        channel_id=int(channel_id),
        packet_type=PacketType(kind),
        seq=int(seq),
        timestamp=float(timestamp),
        flags=[flag for flag in flags.split(",") if flag],
        payload=payload.replace("\\u007c", "|"),
        authenticated=auth == "1",
    )
    return packet, channel_name
