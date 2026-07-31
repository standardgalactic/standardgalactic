from __future__ import annotations

from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from kali_lab.capture_analysis import (
    analyze_capture_file,
    compare_captures,
    export_analysis_json,
    export_flows_csv,
    export_observations_csv,
    export_timeline_csv,
    summarize_analysis,
    timeline_window,
)


class CaptureAnalysisTests(unittest.TestCase):
    def setUp(self) -> None:
        root = Path(__file__).resolve().parents[1]
        self.baseline = root / "fixtures" / "captures" / "normal-mix.pcap"
        self.mixed = root / "fixtures" / "captures" / "mixed-legit-unusual.pcap"
        self.anom = root / "fixtures" / "captures" / "anomalous-mix.pcapng"

    def test_baseline_protocols_detected(self) -> None:
        analysis = analyze_capture_file(self.baseline)
        protocols = analysis["capture"]["protocol_counts"]
        self.assertIn("DNS", protocols)
        self.assertIn("HTTP", protocols)
        self.assertIn("TLS", protocols)

    def test_mixed_capture_not_marked_as_only_malformed(self) -> None:
        analysis = analyze_capture_file(self.mixed)
        malformed = [obs for obs in analysis["observations"] if obs["family"] == "malformed_structure"]
        self.assertEqual(len(malformed), 0)
        self.assertGreater(analysis["capture"]["packet_count"], 0)

    def test_anomalous_capture_has_malformed_observations(self) -> None:
        analysis = analyze_capture_file(self.anom)
        malformed = [obs for obs in analysis["observations"] if obs["family"] == "malformed_structure"]
        self.assertGreaterEqual(len(malformed), 1)

    def test_compare_and_exports(self) -> None:
        diff = compare_captures([self.baseline, self.mixed, self.anom])
        self.assertEqual(len(diff["captures"]), 3)

        analysis = analyze_capture_file(self.baseline)
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            export_analysis_json(analysis, tmp_path / "analysis.json")
            export_flows_csv(analysis, tmp_path / "flows.csv")
            export_timeline_csv(analysis, tmp_path / "timeline.csv")
            export_observations_csv(analysis, tmp_path / "observations.csv")
            self.assertTrue((tmp_path / "analysis.json").exists())
            self.assertTrue((tmp_path / "flows.csv").exists())
            self.assertTrue((tmp_path / "timeline.csv").exists())
            self.assertTrue((tmp_path / "observations.csv").exists())

    def test_summarize_and_timeline_window(self) -> None:
        analysis = analyze_capture_file(self.baseline)
        summary = summarize_analysis(analysis)
        self.assertIn("Evidence established", summary)
        window = timeline_window(analysis, 0.0, 2.0)
        self.assertGreaterEqual(len(window), 1)


if __name__ == "__main__":
    unittest.main()
