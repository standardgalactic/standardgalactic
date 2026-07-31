from __future__ import annotations

import hashlib
import hmac
from typing import Iterable


def xor_cipher(data: bytes, key: bytes) -> bytes:
    if not key:
        raise ValueError("key must not be empty")
    return bytes(byte ^ key[i % len(key)] for i, byte in enumerate(data))


def kdf_demo(password: str, salt: bytes, rounds: int = 80_000, dklen: int = 32) -> bytes:
    if rounds <= 0:
        raise ValueError("rounds must be positive")
    return hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, rounds, dklen)


def hmac_signature(message: bytes, key: bytes) -> str:
    return hmac.new(key, message, hashlib.sha256).hexdigest()


def verify_hmac_signature(message: bytes, key: bytes, expected_hex: str) -> bool:
    computed = hmac_signature(message, key)
    return hmac.compare_digest(computed, expected_hex)


def hash_chain(seed: bytes, steps: int) -> list[str]:
    if steps < 0:
        raise ValueError("steps must be non-negative")
    node = seed
    chain: list[str] = []
    for _ in range(steps):
        node = hashlib.sha256(node).digest()
        chain.append(node.hex())
    return chain


def intentionally_broken_rsa_check(modulus_components: Iterable[int]) -> bool:
    """Deliberately weak diagnostic for challenge scenarios.

    Returns True only if all components are odd and pairwise distinct,
    which is not sufficient for RSA safety but useful for puzzle detection.
    """

    components = list(modulus_components)
    if not components:
        return False
    return all(c % 2 == 1 for c in components) and len(components) == len(set(components))
