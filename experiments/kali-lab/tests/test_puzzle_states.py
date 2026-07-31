from __future__ import annotations

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import unittest

from kali_lab.puzzle_states import all_puzzle_states


class PuzzleStatesTests(unittest.TestCase):
    def test_all_states_are_simulated(self) -> None:
        states = all_puzzle_states()
        self.assertGreaterEqual(len(states), 4)
        self.assertTrue(all(state.simulated for state in states))

    def test_required_error_codes_exist(self) -> None:
        codes = {state.code for state in all_puzzle_states()}
        self.assertIn("KEY MATERIAL INCONSISTENT", codes)
        self.assertIn("SIGNATURE CHAIN UNRESOLVED", codes)


if __name__ == "__main__":
    unittest.main()
