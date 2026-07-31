from __future__ import annotations

import struct
from typing import Literal


class StegoCapacityError(ValueError):
    """Raised when image cannot hold the requested payload."""

    pass


class StegoFormatError(ValueError):
    """Raised when decoding encounters invalid data."""

    pass


def calculate_capacity(width: int, height: int, channels: int = 3, bits_per_channel: int = 1) -> int:
    """Calculate maximum bytes that can be hidden in an image.

    Args:
        width: Image width in pixels
        height: Image height in pixels
        channels: Number of color channels (default 3 for RGB)
        bits_per_channel: LSBs to use per channel (default 1)

    Returns:
        Maximum payload size in bytes (excluding header)
    """
    if width <= 0 or height <= 0 or channels <= 0:
        raise ValueError("dimensions must be positive")
    if bits_per_channel < 1 or bits_per_channel > 8:
        raise ValueError("bits_per_channel must be 1-8")

    total_bits = width * height * channels * bits_per_channel
    header_bytes = 4  # uint32 length prefix
    return (total_bits // 8) - header_bytes


def hide_data(
    image_data: bytes,
    width: int,
    height: int,
    payload: bytes,
    channels: int = 3,
    bits_per_channel: int = 1,
) -> bytes:
    """Hide data in image using LSB steganography.

    Args:
        image_data: Raw pixel data (RGB or RGBA)
        width: Image width
        height: Image height
        payload: Data to hide
        channels: Color channels (3=RGB, 4=RGBA)
        bits_per_channel: LSBs to use per channel

    Returns:
        Modified image data with hidden payload

    Raises:
        StegoCapacityError: If payload too large for image
    """
    if len(image_data) != width * height * channels:
        raise ValueError("image_data size mismatch")

    capacity = calculate_capacity(width, height, channels, bits_per_channel)
    if len(payload) > capacity:
        raise StegoCapacityError(f"payload {len(payload)} bytes exceeds capacity {capacity} bytes")

    # Create length header (4 bytes, big-endian)
    header = struct.pack(">I", len(payload))
    full_payload = header + payload

    # Convert payload to bits
    payload_bits = []
    for byte in full_payload:
        for i in range(7, -1, -1):
            payload_bits.append((byte >> i) & 1)

    # Embed bits into image
    result = bytearray(image_data)
    bit_mask = (1 << bits_per_channel) - 1
    clear_mask = ~bit_mask & 0xFF
    bit_index = 0

    for pixel_index in range(len(result)):
        if bit_index >= len(payload_bits):
            break

        # Extract bits_per_channel worth of payload bits
        value = 0
        for _ in range(bits_per_channel):
            if bit_index < len(payload_bits):
                value = (value << 1) | payload_bits[bit_index]
                bit_index += 1
            else:
                value = value << 1

        # Clear LSBs and set new value
        result[pixel_index] = (result[pixel_index] & clear_mask) | value

    return bytes(result)


def extract_data(
    image_data: bytes,
    width: int,
    height: int,
    channels: int = 3,
    bits_per_channel: int = 1,
) -> bytes:
    """Extract hidden data from image using LSB steganography.

    Args:
        image_data: Raw pixel data containing hidden message
        width: Image width
        height: Image height
        channels: Color channels (3=RGB, 4=RGBA)
        bits_per_channel: LSBs used per channel

    Returns:
        Extracted payload

    Raises:
        StegoFormatError: If data format invalid or corrupted
    """
    if len(image_data) != width * height * channels:
        raise ValueError("image_data size mismatch")

    # Extract bits
    bit_mask = (1 << bits_per_channel) - 1
    extracted_bits = []

    for pixel_index in range(len(image_data)):
        value = image_data[pixel_index] & bit_mask
        for i in range(bits_per_channel - 1, -1, -1):
            extracted_bits.append((value >> i) & 1)

    # Convert bits to bytes
    extracted_bytes = bytearray()
    for i in range(0, len(extracted_bits), 8):
        if i + 8 <= len(extracted_bits):
            byte = 0
            for j in range(8):
                byte = (byte << 1) | extracted_bits[i + j]
            extracted_bytes.append(byte)

    # Read length header
    if len(extracted_bytes) < 4:
        raise StegoFormatError("insufficient data for header")

    payload_length = struct.unpack(">I", bytes(extracted_bytes[:4]))[0]

    # Validate length
    max_capacity = calculate_capacity(width, height, channels, bits_per_channel)
    if payload_length > max_capacity:
        raise StegoFormatError(f"invalid length {payload_length} exceeds capacity {max_capacity}")

    # Extract payload
    if len(extracted_bytes) < 4 + payload_length:
        raise StegoFormatError("insufficient data for declared payload length")

    return bytes(extracted_bytes[4 : 4 + payload_length])


def analyze_lsb_noise(image_data: bytes, channels: int = 3, bits_per_channel: int = 1) -> dict[str, float]:
    """Analyze LSB distribution to detect potential steganography.

    Args:
        image_data: Raw pixel data to analyze
        channels: Color channels
        bits_per_channel: LSBs to analyze

    Returns:
        Dict with 'entropy' and 'chi_squared' metrics
    """
    if not image_data:
        return {"entropy": 0.0, "chi_squared": 0.0}

    bit_mask = (1 << bits_per_channel) - 1
    lsb_values = [byte & bit_mask for byte in image_data]

    # Calculate entropy of LSBs
    counts = {}
    for val in lsb_values:
        counts[val] = counts.get(val, 0) + 1

    entropy = 0.0
    total = len(lsb_values)
    for count in counts.values():
        p = count / total
        if p > 0:
            import math

            entropy -= p * math.log2(p)

    # Chi-squared test (uniform distribution expected)
    expected = total / (1 << bits_per_channel)
    chi_squared = sum((count - expected) ** 2 / expected for count in counts.values())

    return {"entropy": entropy, "chi_squared": chi_squared}


def create_synthetic_image(width: int, height: int, channels: int = 3, seed: int = 42) -> bytes:
    """Create a synthetic image for testing purposes.

    Args:
        width: Image width
        height: Image height
        channels: Color channels
        seed: Random seed for reproducibility

    Returns:
        Raw pixel data
    """
    size = width * height * channels
    # Simple deterministic pattern
    return bytes((seed * i) % 256 for i in range(size))


def stego_diff(original: bytes, modified: bytes) -> dict[str, int | float]:
    """Compare original and stego images to measure changes.

    Args:
        original: Original image data
        modified: Modified image data

    Returns:
        Dict with 'changed_bytes', 'max_delta', 'avg_delta'
    """
    if len(original) != len(modified):
        raise ValueError("images must be same size")

    changed = 0
    total_delta = 0
    max_delta = 0

    for o, m in zip(original, modified):
        delta = abs(o - m)
        if delta > 0:
            changed += 1
            total_delta += delta
            max_delta = max(max_delta, delta)

    return {
        "changed_bytes": changed,
        "max_delta": max_delta,
        "avg_delta": total_delta / len(original) if original else 0.0,
    }
