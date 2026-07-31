from __future__ import annotations

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import unittest

from kali_lab.protocol_lab import LocalOnlyTransport, is_local_endpoint


class LocalNetworkBoundaryTests(unittest.TestCase):
    def test_local_endpoint_check(self) -> None:
        self.assertTrue(is_local_endpoint("localhost:8080"))
        self.assertTrue(is_local_endpoint("127.0.0.1:9000"))
        self.assertFalse(is_local_endpoint("example.com:443"))

    def test_transport_rejects_non_local_targets(self) -> None:
        transport = LocalOnlyTransport()
        transport.send("localhost:9443", "ok")
        with self.assertRaises(ValueError):
            transport.send("example.com:443", "blocked")


if __name__ == "__main__":
    unittest.main()
