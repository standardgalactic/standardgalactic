from __future__ import annotations

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from kali_lab.crypto_toys import hash_chain, hmac_signature, kdf_demo, verify_hmac_signature, xor_cipher


class CryptoToysTests(unittest.TestCase):
    def test_xor_round_trip(self) -> None:
        plain = b"lab-data"
        key = b"k"
        cipher = xor_cipher(plain, key)
        self.assertEqual(xor_cipher(cipher, key), plain)

    def test_kdf_and_signature(self) -> None:
        key = kdf_demo("pw", b"salt", rounds=1000, dklen=16)
        signature = hmac_signature(b"msg", key)
        self.assertTrue(verify_hmac_signature(b"msg", key, signature))

    def test_hash_chain_length(self) -> None:
        self.assertEqual(len(hash_chain(b"seed", 5)), 5)


if __name__ == "__main__":
    unittest.main()
