from __future__ import annotations

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from kali_lab.capture_ingest import read_capture


class CaptureIngestTests(unittest.TestCase):
    def setUp(self) -> None:
        self.root = Path(__file__).resolve().parents[1]

    def test_reads_pcap_fixture(self) -> None:
        packets, warnings = read_capture(self.root / "fixtures" / "captures" / "normal-mix.pcap")
        self.assertGreaterEqual(len(packets), 6)
        self.assertIsInstance(warnings, list)

    def test_reads_pcapng_fixture_with_warnings(self) -> None:
        packets, warnings = read_capture(self.root / "fixtures" / "captures" / "anomalous-mix.pcapng")
        self.assertGreaterEqual(len(packets), 2)
        self.assertIsInstance(warnings, list)


if __name__ == "__main__":
    unittest.main()
