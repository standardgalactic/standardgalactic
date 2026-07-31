from __future__ import annotations

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import unittest

from kali_lab.protocol_lab import ProtocolState, replay_transcript


class ProtocolLabTests(unittest.TestCase):
    def test_replay_accepts_valid_sequence(self) -> None:
        state = replay_transcript(["CLIENT_HELLO", "KEY_SHARE", "VERIFY_OK"])
        self.assertEqual(state, ProtocolState.VERIFIED)

    def test_replay_rejects_invalid_sequence(self) -> None:
        state = replay_transcript(["VERIFY_OK"])
        self.assertEqual(state, ProtocolState.REJECTED)


if __name__ == "__main__":
    unittest.main()
