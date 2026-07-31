from __future__ import annotations

import struct
from pathlib import Path

from .capture_models import PacketRecord


class CaptureFormatError(ValueError):
    pass


_PCAP_ENDIANNESS = {
    b"\xd4\xc3\xb2\xa1": ("<", "us"),
    b"\xa1\xb2\xc3\xd4": (">", "us"),
    b"\x4d\x3c\xb2\xa1": ("<", "ns"),
    b"\xa1\xb2\x3c\x4d": (">", "ns"),
}


def detect_capture_format(raw: bytes) -> str:
    if len(raw) < 4:
        raise CaptureFormatError("capture is too short")
    magic = raw[:4]
    if magic in _PCAP_ENDIANNESS:
        return "pcap"
    if magic == b"\x0a\x0d\x0d\x0a":
        return "pcapng"
    raise CaptureFormatError("unsupported capture format: expected pcap or pcapng")


def read_capture(path: str | Path) -> tuple[list[PacketRecord], list[str]]:
    file_path = Path(path)
    raw = file_path.read_bytes()
    fmt = detect_capture_format(raw)
    if fmt == "pcap":
        return _read_pcap(raw, file_path.name)
    return _read_pcapng(raw, file_path.name)


def _read_pcap(raw: bytes, source: str) -> tuple[list[PacketRecord], list[str]]:
    if len(raw) < 24:
        raise CaptureFormatError("invalid pcap header")

    endian, ts_unit = _PCAP_ENDIANNESS[raw[:4]]
    warnings: list[str] = []
    records: list[PacketRecord] = []
    offset = 24
    index = 0

    while offset + 16 <= len(raw):
        ts_sec, ts_frac, incl_len, orig_len = struct.unpack_from(f"{endian}IIII", raw, offset)
        offset += 16
        if offset + incl_len > len(raw):
            warnings.append(f"truncated_packet_record:index={index}")
            break

        unit_divisor = 1_000_000_000.0 if ts_unit == "ns" else 1_000_000.0
        timestamp = float(ts_sec) + (float(ts_frac) / unit_divisor)
        payload = raw[offset : offset + incl_len]
        offset += incl_len

        parse_warnings: list[str] = []
        if incl_len != orig_len:
            parse_warnings.append("capture_length_differs_from_original")

        records.append(
            PacketRecord(
                index=index,
                timestamp=timestamp,
                captured_length=incl_len,
                original_length=orig_len,
                data=payload,
                source=source,
                parse_warnings=parse_warnings,
            )
        )
        index += 1

    if offset < len(raw):
        warnings.append("trailing_bytes_ignored")

    return records, warnings


def _read_pcapng(raw: bytes, source: str) -> tuple[list[PacketRecord], list[str]]:
    warnings: list[str] = []
    records: list[PacketRecord] = []
    offset = 0
    endian = "<"
    ts_scale = 1e-6
    index = 0

    while offset + 12 <= len(raw):
        if offset + 8 > len(raw):
            warnings.append("pcapng_truncated_block_header")
            break

        block_type_le = int.from_bytes(raw[offset : offset + 4], "little")
        block_len = int.from_bytes(raw[offset + 4 : offset + 8], "little")

        if block_len < 12:
            warnings.append(f"pcapng_invalid_block_length:{block_len}")
            break
        if offset + block_len > len(raw):
            warnings.append("pcapng_truncated_block")
            break

        block = raw[offset : offset + block_len]

        if block_type_le == 0x0A0D0D0A and len(block) >= 28:
            bom = block[8:12]
            if bom == b"\x4d\x3c\x2b\x1a":
                endian = "<"
            elif bom == b"\x1a\x2b\x3c\x4d":
                endian = ">"
            else:
                warnings.append("pcapng_unknown_bom_defaulting_little_endian")

        elif block_type_le == 0x00000001:
            ts_scale = 1e-6

        elif block_type_le == 0x00000006:
            if len(block) < 32:
                warnings.append("pcapng_short_epb")
                offset += block_len
                continue

            _, ts_high, ts_low, cap_len, orig_len = struct.unpack_from(f"{endian}IIIII", block, 8)
            start = 28
            end = start + cap_len
            if end > len(block) - 4:
                warnings.append(f"pcapng_truncated_epb:index={index}")
                offset += block_len
                continue

            payload = block[start:end]
            timestamp = ((ts_high << 32) | ts_low) * ts_scale
            parse_warnings: list[str] = []
            if cap_len != orig_len:
                parse_warnings.append("capture_length_differs_from_original")

            records.append(
                PacketRecord(
                    index=index,
                    timestamp=float(timestamp),
                    captured_length=cap_len,
                    original_length=orig_len,
                    data=payload,
                    source=source,
                    parse_warnings=parse_warnings,
                )
            )
            index += 1

        offset += block_len

    if not records:
        warnings.append("pcapng_contains_no_packet_records")

    return records, warnings
