from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Protocol


class TransportAdapter(Protocol):
    def send(self, envelope: bytes) -> None: ...

    def receive(self) -> bytes | None: ...


@dataclass
class InMemoryAdapter:
    queue: deque[bytes] = field(default_factory=deque)

    def send(self, envelope: bytes) -> None:
        self.queue.append(envelope)

    def receive(self) -> bytes | None:
        if not self.queue:
            return None
        return self.queue.popleft()


@dataclass
class LocalhostSimulationAdapter:
    """Offline transport simulation that mimics reconnectable localhost links."""

    queue: deque[bytes] = field(default_factory=deque)
    connected: bool = True

    def send(self, envelope: bytes) -> None:
        if self.connected:
            self.queue.append(envelope)

    def receive(self) -> bytes | None:
        if not self.connected or not self.queue:
            return None
        return self.queue.popleft()

    def disconnect(self) -> None:
        self.connected = False

    def reconnect(self) -> None:
        self.connected = True
