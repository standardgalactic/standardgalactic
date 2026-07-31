# Steganography Toolkit Quick Reference

## Overview

The steganography toolkit implements LSB (Least Significant Bit) steganography for hiding data in images. It supports multiple bit depths and provides analysis tools to detect and measure steganographic content.

## Core Functions

### `hide_data(image_data, width, height, payload, channels=3, bits_per_channel=1)`
Hide data in an image using LSB steganography.

**Parameters:**
- `image_data`: Raw pixel data (bytes)
- `width`, `height`: Image dimensions
- `payload`: Data to hide (bytes)
- `channels`: 3 for RGB, 4 for RGBA
- `bits_per_channel`: Number of LSBs to use (1-8)

**Returns:** Modified image data with hidden payload

### `extract_data(image_data, width, height, channels=3, bits_per_channel=1)`
Extract hidden data from an image.

**Parameters:**
- `image_data`: Image containing hidden data (bytes)
- `width`, `height`: Image dimensions
- `channels`: 3 for RGB, 4 for RGBA
- `bits_per_channel`: Number of LSBs used (1-8)

**Returns:** Extracted payload (bytes)

### `calculate_capacity(width, height, channels=3, bits_per_channel=1)`
Calculate maximum bytes that can be hidden in an image.

**Returns:** Maximum payload size in bytes

## Analysis Functions

### `analyze_lsb_noise(image_data, channels=3, bits_per_channel=1)`
Analyze LSB distribution to detect potential steganography.

**Returns:** Dict with `entropy` and `chi_squared` metrics

### `stego_diff(original, modified)`
Compare original and stego images to measure changes.

**Returns:** Dict with `changed_bytes`, `max_delta`, `avg_delta`

## Utility Functions

### `create_synthetic_image(width, height, channels=3, seed=42)`
Create a deterministic synthetic image for testing.

**Returns:** Raw pixel data (bytes)

## Example Workflows

### Basic Hide/Extract
```python
from kali_lab.stego_kit import hide_data, extract_data, create_synthetic_image

# Create test image
image = create_synthetic_image(100, 100, channels=3)

# Hide message
secret = b"My secret message"
stego = hide_data(image, 100, 100, secret)

# Extract message
recovered = extract_data(stego, 100, 100)
assert recovered == secret
```

### Check Capacity First
```python
from kali_lab.stego_kit import calculate_capacity, hide_data

width, height = 200, 150
capacity = calculate_capacity(width, height, channels=3, bits_per_channel=1)
print(f"Can hide {capacity} bytes")  # 11,246 bytes

# Only hide if payload fits
payload = b"Your data here"
if len(payload) <= capacity:
    stego = hide_data(image, width, height, payload)
```

### Multi-Bit Steganography
```python
# Use more bits for higher capacity (but more visible changes)
capacity_1bit = calculate_capacity(100, 100, bits_per_channel=1)  # 3,746 bytes
capacity_2bit = calculate_capacity(100, 100, bits_per_channel=2)  # 7,496 bytes
capacity_4bit = calculate_capacity(100, 100, bits_per_channel=4)  # 14,996 bytes

# Hide with 2 bits per channel
stego = hide_data(image, 100, 100, payload, bits_per_channel=2)
recovered = extract_data(stego, 100, 100, bits_per_channel=2)
```

### Steganalysis
```python
from kali_lab.stego_kit import analyze_lsb_noise, stego_diff

# Measure changes
diff = stego_diff(original, stego)
print(f"Changed {diff['changed_bytes']} pixels")
print(f"Max pixel change: {diff['max_delta']}")
print(f"Average change: {diff['avg_delta']:.6f}")

# Analyze LSB distribution
analysis = analyze_lsb_noise(stego, channels=3)
print(f"LSB Entropy: {analysis['entropy']:.4f}")
print(f"Chi-squared: {analysis['chi_squared']:.2f}")

# High chi-squared suggests non-random LSBs (possible steganography)
# Low entropy with high chi-squared = likely hidden data
```

## Capacity Table (100x100 RGB image)

| Bits/Channel | Capacity  | Visual Impact |
|--------------|-----------|---------------|
| 1            | 3.7 KB    | Imperceptible |
| 2            | 7.5 KB    | Barely visible|
| 3            | 11.2 KB   | Slight noise  |
| 4            | 15.0 KB   | Noticeable    |
| 8            | 30.0 KB   | Severe        |

## Error Handling

- `StegoCapacityError`: Payload too large for image capacity
- `StegoFormatError`: Invalid or corrupted hidden data during extraction
- `ValueError`: Invalid parameters (dimensions, bit depth, etc.)

## Best Practices

1. **Use 1-2 bits per channel** for undetectable steganography
2. **Always check capacity** before hiding data
3. **Use lossless formats** (PNG, BMP) - JPEG compression destroys hidden data
4. **Analyze before/after** with `stego_diff()` to verify minimal changes
5. **Test roundtrip** (hide → extract) to ensure data integrity

## Educational Notes

This toolkit is designed for:
- Learning steganography principles
- Understanding LSB encoding techniques
- Practicing steganalysis and detection
- Experimenting with trade-offs between capacity and detectability

**Not suitable for:** Real-world security applications (use professional tools like steghide, outguess, or modern crypto-steganography).
