from __future__ import annotations

import pytest

from kali_lab.stego_kit import (
    StegoCapacityError,
    StegoFormatError,
    analyze_lsb_noise,
    calculate_capacity,
    create_synthetic_image,
    extract_data,
    hide_data,
    stego_diff,
)


def test_calculate_capacity() -> None:
    capacity = calculate_capacity(100, 100, channels=3, bits_per_channel=1)
    assert capacity == 3746  # (100*100*3*1 / 8) - 4 header bytes

    with pytest.raises(ValueError):
        calculate_capacity(0, 100)


def test_hide_and_extract_roundtrip() -> None:
    width, height = 50, 50
    image = create_synthetic_image(width, height, channels=3)
    payload = b"secret message"

    stego_image = hide_data(image, width, height, payload)
    recovered = extract_data(stego_image, width, height)

    assert recovered == payload


def test_hide_capacity_exceeded() -> None:
    width, height = 10, 10
    image = create_synthetic_image(width, height, channels=3)
    large_payload = b"x" * 500

    with pytest.raises(StegoCapacityError):
        hide_data(image, width, height, large_payload)


def test_extract_empty_image() -> None:
    width, height = 20, 20
    image = create_synthetic_image(width, height, channels=3)

    with pytest.raises(StegoFormatError):
        extract_data(image, width, height)


def test_hide_data_size_mismatch() -> None:
    with pytest.raises(ValueError):
        hide_data(b"short", 100, 100, b"data")


def test_extract_data_size_mismatch() -> None:
    with pytest.raises(ValueError):
        extract_data(b"short", 100, 100)


def test_different_bits_per_channel() -> None:
    width, height = 40, 40
    payload = b"testing with 2 bits per channel"

    for bits in [1, 2, 4]:
        image = create_synthetic_image(width, height, channels=3, seed=bits)
        capacity = calculate_capacity(width, height, bits_per_channel=bits)

        if len(payload) <= capacity:
            stego_image = hide_data(image, width, height, payload, bits_per_channel=bits)
            recovered = extract_data(stego_image, width, height, bits_per_channel=bits)
            assert recovered == payload


def test_rgba_image() -> None:
    width, height = 30, 30
    image = create_synthetic_image(width, height, channels=4)
    payload = b"RGBA test"

    stego_image = hide_data(image, width, height, payload, channels=4)
    recovered = extract_data(stego_image, width, height, channels=4)

    assert recovered == payload


def test_analyze_lsb_noise() -> None:
    image = create_synthetic_image(50, 50, channels=3)
    analysis = analyze_lsb_noise(image, channels=3, bits_per_channel=1)

    assert "entropy" in analysis
    assert "chi_squared" in analysis
    assert analysis["entropy"] >= 0


def test_stego_diff() -> None:
    width, height = 25, 25
    original = create_synthetic_image(width, height, channels=3)
    payload = b"hidden"

    stego_image = hide_data(original, width, height, payload)
    diff = stego_diff(original, stego_image)

    assert diff["changed_bytes"] > 0
    assert diff["max_delta"] <= 1  # LSB changes should be minimal
    assert diff["avg_delta"] >= 0


def test_stego_diff_size_mismatch() -> None:
    with pytest.raises(ValueError):
        stego_diff(b"short", b"longer data")


def test_max_capacity_usage() -> None:
    width, height = 20, 20
    capacity = calculate_capacity(width, height, channels=3, bits_per_channel=1)
    max_payload = b"x" * capacity

    image = create_synthetic_image(width, height, channels=3)
    stego_image = hide_data(image, width, height, max_payload)
    recovered = extract_data(stego_image, width, height)

    assert recovered == max_payload


def test_empty_payload() -> None:
    width, height = 15, 15
    image = create_synthetic_image(width, height, channels=3)
    payload = b""

    stego_image = hide_data(image, width, height, payload)
    recovered = extract_data(stego_image, width, height)

    assert recovered == payload


def test_binary_payload() -> None:
    width, height = 30, 30
    image = create_synthetic_image(width, height, channels=3)
    payload = bytes(range(256))[:100]  # Binary data with all byte values

    stego_image = hide_data(image, width, height, payload)
    recovered = extract_data(stego_image, width, height)

    assert recovered == payload


def test_analyze_empty_image() -> None:
    analysis = analyze_lsb_noise(b"", channels=3)
    assert analysis["entropy"] == 0.0
    assert analysis["chi_squared"] == 0.0
