from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class ProtocolState(str, Enum):
    INIT = "INIT"
    HELLO = "HELLO"
    KEY_EXCHANGE = "KEY_EXCHANGE"
    VERIFIED = "VERIFIED"
    REJECTED = "REJECTED"


def is_local_endpoint(endpoint: str) -> bool:
    lowered = endpoint.lower()
    return lowered.startswith("localhost") or lowered.startswith("127.0.0.1")


@dataclass
class LocalOnlyTransport:
    sent_messages: list[tuple[str, str]]

    def __init__(self) -> None:
        self.sent_messages = []

    def send(self, endpoint: str, payload: str) -> None:
        if not is_local_endpoint(endpoint):
            raise ValueError("non-local endpoint rejected by lab boundary")
        self.sent_messages.append((endpoint, payload))


def replay_transcript(lines: list[str]) -> ProtocolState:
    state = ProtocolState.INIT
    for line in lines:
        cleaned = line.strip()
        if not cleaned or cleaned.startswith("#"):
            continue
        if cleaned == "CLIENT_HELLO" and state == ProtocolState.INIT:
            state = ProtocolState.HELLO
        elif cleaned == "KEY_SHARE" and state == ProtocolState.HELLO:
            state = ProtocolState.KEY_EXCHANGE
        elif cleaned == "VERIFY_OK" and state == ProtocolState.KEY_EXCHANGE:
            state = ProtocolState.VERIFIED
        else:
            state = ProtocolState.REJECTED
            break
    return state
