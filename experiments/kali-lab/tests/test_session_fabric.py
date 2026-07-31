from __future__ import annotations

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from kali_lab.session_fabric import FabricPacket, PacketType, SessionFabric
from kali_lab.transport_adapters import InMemoryAdapter, LocalhostSimulationAdapter


class SessionFabricTests(unittest.TestCase):
    def test_replay_and_priority(self) -> None:
        fabric = SessionFabric()
        fabric.route_packet(
            FabricPacket(7, 2, PacketType.STDIN, 5, 1.0, ["interactive"], "ls\n"),
            channel_name="editor",
        )
        fabric.route_packet(
            FabricPacket(7, 0, PacketType.FILE, 1, 2.0, ["bulk"], "chunk"),
            channel_name="transfer",
        )
        fabric.route_packet(
            FabricPacket(7, 1, PacketType.SIGNAL, 3, 1.5, ["interrupt"], "CTRL-C"),
            channel_name="shell",
        )

        replay = fabric.attach_replay(7, {2: 1, 0: 1, 1: 0})
        self.assertEqual(len(replay), 2)

        prioritized = fabric.prioritized_packets(7)
        self.assertEqual(prioritized[0].packet_type, PacketType.SIGNAL)

    def test_session_survives_transport_swap_and_reconnect(self) -> None:
        source = SessionFabric()
        target = SessionFabric()
        in_mem = InMemoryAdapter()
        local = LocalhostSimulationAdapter()

        source.bind_transport(in_mem)
        target.bind_transport(in_mem)
        source.route_packet(
            FabricPacket(9, 0, PacketType.COMMAND, 1, 1.0, ["auth"], "run job"),
            channel_name="shell",
        )
        target.ingest_transport()
        self.assertIn(9, target.sessions)
        self.assertEqual(target.sessions[9].session_id, 9)

        # Replace transport without changing logical session identity.
        source.bind_transport(local)
        target.bind_transport(local)
        local.disconnect()
        source.route_packet(
            FabricPacket(9, 0, PacketType.STDOUT, 2, 1.2, ["stream"], "pending"),
            channel_name="shell",
        )
        self.assertEqual(target.ingest_transport(), 0)

        local.reconnect()
        source.route_packet(
            FabricPacket(9, 1, PacketType.STDIN, 3, 1.3, ["interactive"], "attach\\n"),
            channel_name="editor",
        )
        consumed = target.ingest_transport()
        self.assertEqual(consumed, 1)
        self.assertEqual(target.sessions[9].session_id, 9)
        self.assertIn(1, target.sessions[9].channels)


if __name__ == "__main__":
    unittest.main()
