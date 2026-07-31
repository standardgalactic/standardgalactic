# Kali Lab

A local-only security research laboratory inspired by the breadth and technical depth of Kali-style workflows.

This directory contains synthetic, auditable experiments for:

- cryptography and key-format edge cases
- protocol state-machine analysis
- malformed signature and key puzzles
- forensic entropy and artifact analysis
- **steganography (LSB image encoding/decoding)**
- legacy/odd format decoding drills
- passive PCAP/PCAPNG network-forensics analysis
- typed packet session-fabric experiments for persistent terminal state

## Safety boundary

All features are intentionally constrained to local fixtures and offline analysis.
See [`THREAT_MODEL.md`](THREAT_MODEL.md).

## Run demos

```bash
python3 -m kali_lab.cli --demo all
```

Run an individual demo:

```bash
python3 -m kali_lab.cli --demo crypto
python3 -m kali_lab.cli --demo protocol
python3 -m kali_lab.cli --demo forensics
python3 -m kali_lab.cli --demo puzzles
python3 -m kali_lab.cli --demo stego
python3 -m kali_lab.cli --demo capture --capture-file fixtures/captures/normal-mix.pcap --export-dir /tmp/kali-export
python3 -m kali_lab.cli --demo compare --compare-files fixtures/captures/normal-mix.pcap fixtures/captures/mixed-legit-unusual.pcap fixtures/captures/anomalous-mix.pcapng
python3 -m kali_lab.cli --demo summarize --capture-file fixtures/captures/mixed-legit-unusual.pcap
python3 -m kali_lab.cli --demo fabric
```

## Steganography toolkit

Hide and extract secret messages in images using LSB (Least Significant Bit) steganography.

**Features:**
- Hide data in RGB/RGBA images using configurable LSB depth (1-8 bits per channel)
- Extract hidden data with automatic length detection
- Capacity calculation for different image sizes and bit depths
- LSB noise analysis to detect potential steganography
- Stego-diff to measure changes between original and stego images
- Minimal visual impact (max 1-bit change per pixel at default settings)

**Example usage:**

```python
from kali_lab.stego_kit import (
    hide_data, extract_data, calculate_capacity, 
    create_synthetic_image, stego_diff, analyze_lsb_noise
)

# Create or load an image (raw pixel data)
width, height = 100, 100
image = create_synthetic_image(width, height, channels=3)

# Check capacity
capacity = calculate_capacity(width, height, channels=3, bits_per_channel=1)
print(f"Can hide up to {capacity} bytes")  # 3746 bytes

# Hide secret message
secret = b"Top secret information!"
stego_image = hide_data(image, width, height, secret)

# Analyze changes
diff = stego_diff(image, stego_image)
print(f"Changed {diff['changed_bytes']} bytes, max delta: {diff['max_delta']}")

# Extract message
recovered = extract_data(stego_image, width, height)
assert recovered == secret  # Success!

# Detect potential steganography
analysis = analyze_lsb_noise(stego_image, channels=3)
print(f"LSB entropy: {analysis['entropy']:.4f}")
print(f"Chi-squared: {analysis['chi_squared']:.4f}")
```

## Capture analysis subsystem

- First-class binary ingestion for `.pcap` and `.pcapng`
- Graceful handling of truncated/corrupt records without aborting full analysis
- Layered architecture:
  1. parser (`capture_ingest.py`)
  2. event normalization (`capture_normalize.py`)
  3. flow/session reconstruction (`flow_reconstruct.py`)
  4. forensic interpretation/export (`capture_analysis.py`)
- Canonical bidirectional flows with direction-aware counters (`A_TO_B`, `B_TO_A`)
- Transport-independent `session_fabric` semantics with minimal pluggable transport adapters
- DNS/HTTP/TLS metadata extraction where observable in passive captures
- Timeline-first output plus anomaly evidence families and inspectable score components
- JSON hierarchy + flattened CSV exports for NumPy/pandas/NLTK workflows

### Bring your own captures

Place lab-owned files in:

- `fixtures/captures/imports/`

Then run:

```bash
python3 -m kali_lab.cli --demo capture --capture-file fixtures/captures/imports/<your-file>.pcap --export-dir /tmp/kali-export
```

## Run tests

```bash
python3 -m unittest discover -s tests -p "test_*.py"
```
