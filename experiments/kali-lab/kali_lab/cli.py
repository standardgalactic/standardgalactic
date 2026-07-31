from __future__ import annotations

import argparse
import json
from pathlib import Path

from .capture_analysis import (
    analyze_capture_file,
    compare_captures,
    export_analysis_json,
    export_flows_csv,
    export_observations_csv,
    export_timeline_csv,
    summarize_analysis,
    timeline_window,
)
from .crypto_toys import hash_chain, hmac_signature, intentionally_broken_rsa_check, kdf_demo, xor_cipher
from .forensic_lab import lsb_bias_score, parse_legacy_container, shannon_entropy
from .protocol_lab import LocalOnlyTransport, replay_transcript
from .puzzle_states import all_puzzle_states
from .session_fabric import FabricPacket, PacketType, SessionFabric
from .stego_kit import (
    analyze_lsb_noise,
    calculate_capacity,
    create_synthetic_image,
    extract_data,
    hide_data,
    stego_diff,
)

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "fixtures"
CAPTURES = FIXTURES / "captures"


def _load_json(name: str) -> dict:
    with (FIXTURES / name).open("r", encoding="utf-8") as handle:
        return json.load(handle)


def run_crypto_demo() -> None:
    payload = b"anomalous-material"
    key = b"lab"
    ciphertext = xor_cipher(payload, key)
    recovered = xor_cipher(ciphertext, key)
    derived = kdf_demo("passphrase", b"zygote-lab", rounds=1_000, dklen=16)
    signature = hmac_signature(payload, derived)
    weak_check = intentionally_broken_rsa_check([17, 31, 53])
    print("[crypto] xor-roundtrip=", recovered == payload)
    print("[crypto] signature=", signature[:16] + "...")
    print("[crypto] weak-rsa-diagnostic=", weak_check)
    print("[crypto] hash-chain-tail=", hash_chain(b"seed", 3)[-1][:20] + "...")


def run_protocol_demo() -> None:
    transcript = (FIXTURES / "protocol_transcripts.txt").read_text(encoding="utf-8").splitlines()
    final_state = replay_transcript(transcript)
    transport = LocalOnlyTransport()
    transport.send("localhost:9443", "LAB_HELLO")
    print("[protocol] final-state=", final_state.value)
    print("[protocol] sent-messages=", len(transport.sent_messages))


def run_forensics_demo() -> None:
    envelope = _load_json("corrupted_envelopes.json")
    sample = bytes.fromhex(envelope["blob_hex"])
    entropy = shannon_entropy(sample)
    bias = lsb_bias_score(sample)
    parsed = parse_legacy_container("ALG:legacy-rsa|kdf=pbkdf2|rounds:120000|noise")
    print("[forensics] entropy=", f"{entropy:.4f}")
    print("[forensics] lsb-bias=", f"{bias:.4f}")
    print("[forensics] parsed-fields=", sorted(parsed.keys()))


def run_puzzles_demo() -> None:
    challenge = _load_json("challenge_vectors.json")
    print("[puzzles] fixture-id=", challenge["fixture_id"])
    for state in all_puzzle_states():
        print(f"[puzzles] {state.code} :: simulated={state.simulated}")


def run_capture_demo(capture_file: Path, export_dir: Path | None, start: float | None, end: float | None) -> None:
    analysis = analyze_capture_file(capture_file)
    print("[capture] source=", analysis["capture"]["source"])
    print("[capture] packets=", analysis["capture"]["packet_count"])
    print("[capture] protocols=", analysis["capture"]["protocol_counts"])
    print("[capture] parser-warnings=", analysis["capture"]["parser_warnings"])
    print("[capture] anomaly-components=", analysis["capture"]["composite_anomaly_score"])

    if start is not None and end is not None:
        window = timeline_window(analysis, start, end)
        print(f"[capture] timeline-window {start}..{end}: {len(window)} events")

    if export_dir:
        export_dir.mkdir(parents=True, exist_ok=True)
        export_analysis_json(analysis, export_dir / "analysis.json")
        export_flows_csv(analysis, export_dir / "flows.csv")
        export_timeline_csv(analysis, export_dir / "timeline.csv")
        export_observations_csv(analysis, export_dir / "observations.csv")
        print("[capture] exports=", str(export_dir))


def run_compare_demo(capture_files: list[Path]) -> None:
    result = compare_captures(capture_files)
    print("[compare] captures=", result["captures"])
    print("[compare] flow-counts=", result["flow_counts"])
    print("[compare] protocol-composition=", result["protocol_composition"])
    print("[compare] anomaly-families=", result["anomaly_families"])


def run_summarize_demo(capture_file: Path) -> None:
    analysis = analyze_capture_file(capture_file)
    print(summarize_analysis(analysis))


def run_fabric_demo() -> None:
    fabric = SessionFabric()
    fabric.route_packet(
        FabricPacket(
            session_id=7,
            channel_id=2,
            packet_type=PacketType.STDIN,
            seq=18421,
            timestamp=1.0,
            flags=["interactive"],
            payload=":wq\\n",
        ),
        channel_name="editor",
    )
    fabric.route_packet(
        FabricPacket(
            session_id=7,
            channel_id=1,
            packet_type=PacketType.STDOUT,
            seq=923104,
            timestamp=1.01,
            flags=["log"],
            payload="worker 81 completed\\n",
        ),
        channel_name="logs",
    )
    fabric.route_packet(
        FabricPacket(
            session_id=7,
            channel_id=3,
            packet_type=PacketType.FILE,
            seq=10,
            timestamp=1.2,
            flags=["bulk"],
            payload="artifact-chunk",
        ),
        channel_name="long-job",
    )
    fabric.route_packet(
        FabricPacket(
            session_id=7,
            channel_id=0,
            packet_type=PacketType.SIGNAL,
            seq=483,
            timestamp=1.21,
            flags=["interrupt"],
            payload="CTRL-C",
        ),
        channel_name="shell",
    )

    replay = fabric.attach_replay(7, {0: 400, 1: 920188, 2: 17000, 3: 0})
    prioritized = fabric.prioritized_packets(7)
    print("[fabric] session=7 channels=", sorted(fabric.sessions[7].channels.keys()))
    print("[fabric] replay-packets=", len(replay))
    print("[fabric] first-priority-packet=", prioritized[0].packet_type.value if prioritized else "none")


def run_stego_demo() -> None:
    width, height = 100, 100
    channels = 3
    secret_message = b"Steganography: the art of hiding messages in plain sight!"

    print("[stego] image-dimensions=", f"{width}x{height}")
    print("[stego] channels=", channels)

    capacity = calculate_capacity(width, height, channels, bits_per_channel=1)
    print("[stego] max-capacity=", capacity, "bytes")

    original_image = create_synthetic_image(width, height, channels)
    print("[stego] original-image-size=", len(original_image), "bytes")

    stego_image = hide_data(original_image, width, height, secret_message, channels)
    print("[stego] secret-message=", secret_message[:40].decode("utf-8", errors="replace") + "...")

    diff = stego_diff(original_image, stego_image)
    print("[stego] bytes-changed=", diff["changed_bytes"])
    print("[stego] max-pixel-delta=", diff["max_delta"])
    print(f"[stego] avg-pixel-delta= {diff['avg_delta']:.6f}")

    analysis = analyze_lsb_noise(stego_image, channels)
    print(f"[stego] lsb-entropy= {analysis['entropy']:.4f}")
    print(f"[stego] lsb-chi-squared= {analysis['chi_squared']:.4f}")

    recovered_message = extract_data(stego_image, width, height, channels)
    print("[stego] recovery-success=", recovered_message == secret_message)
    print("[stego] recovered-message=", recovered_message[:40].decode("utf-8", errors="replace") + "...")

    for bits in [1, 2, 4]:
        cap = calculate_capacity(width, height, channels, bits_per_channel=bits)
        print(f"[stego] capacity-at-{bits}-bit(s)=", cap, "bytes")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Kali Lab demonstrations")
    parser.add_argument(
        "--demo",
        choices=["all", "crypto", "protocol", "forensics", "puzzles", "capture", "compare", "summarize", "fabric", "stego"],
        default="all",
        help="Select which local lab demo to run",
    )
    parser.add_argument(
        "--capture-file",
        type=Path,
        default=CAPTURES / "normal-mix.pcap",
        help="Path to .pcap or .pcapng file for capture analysis",
    )
    parser.add_argument(
        "--compare-files",
        nargs="+",
        type=Path,
        default=[CAPTURES / "normal-mix.pcap", CAPTURES / "mixed-legit-unusual.pcap", CAPTURES / "anomalous-mix.pcapng"],
        help="Two or more capture files to compare",
    )
    parser.add_argument(
        "--export-dir",
        type=Path,
        default=None,
        help="Optional directory for JSON/CSV export",
    )
    parser.add_argument("--timeline-start", type=float, default=None, help="Optional relative timeline window start")
    parser.add_argument("--timeline-end", type=float, default=None, help="Optional relative timeline window end")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if args.demo in {"all", "crypto"}:
        run_crypto_demo()
    if args.demo in {"all", "protocol"}:
        run_protocol_demo()
    if args.demo in {"all", "forensics"}:
        run_forensics_demo()
    if args.demo in {"all", "puzzles"}:
        run_puzzles_demo()
    if args.demo in {"all", "capture"}:
        run_capture_demo(args.capture_file, args.export_dir, args.timeline_start, args.timeline_end)
    if args.demo == "compare":
        run_compare_demo(args.compare_files)
    if args.demo == "summarize":
        run_summarize_demo(args.capture_file)
    if args.demo in {"all", "fabric"}:
        run_fabric_demo()
    if args.demo in {"all", "stego"}:
        run_stego_demo()


if __name__ == "__main__":
    main()
