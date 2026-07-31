from __future__ import annotations

import math
from collections import Counter


def shannon_entropy(data: bytes) -> float:
    if not data:
        return 0.0
    counts = Counter(data)
    size = len(data)
    entropy = 0.0
    for count in counts.values():
        probability = count / size
        entropy -= probability * math.log2(probability)
    return entropy


def byte_histogram(data: bytes) -> dict[int, int]:
    return dict(Counter(data))


def lsb_bias_score(data: bytes) -> float:
    if not data:
        return 0.0
    ones = sum(byte & 1 for byte in data)
    zeros = len(data) - ones
    return abs(ones - zeros) / len(data)


def parse_legacy_container(blob: str) -> dict[str, str]:
    """Parse synthetic legacy container records.

    Format supports mixed separators (`:`, `=`) and ignores malformed fields.
    """

    parsed: dict[str, str] = {}
    for token in blob.split("|"):
        token = token.strip()
        if not token:
            continue
        if ":" in token:
            key, value = token.split(":", 1)
        elif "=" in token:
            key, value = token.split("=", 1)
        else:
            continue
        parsed[key.strip().lower()] = value.strip()
    return parsed
