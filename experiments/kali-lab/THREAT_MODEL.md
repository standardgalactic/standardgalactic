# Threat Model: Kali Lab

## Purpose

Kali Lab is an educational and research subsystem for advanced security analysis using synthetic data, deliberately broken artifacts, and challenge-style cryptographic puzzles.

## Explicit safety boundary

- No stealth behavior.
- No process hiding.
- No persistence mechanisms.
- No credential collection.
- No external host scanning.
- No live exploit delivery.
- No non-localhost network transport.

## Allowed behavior

- Local fixture parsing and analysis.
- Offline protocol transcript analysis.
- Simulated cryptographic failure states.
- Localhost-only mock transport for protocol exercises.
- Deterministic challenge vectors with authored inconsistencies.
- Passive offline packet-capture forensics from `.pcap` / `.pcapng` inputs.
- Typed packet session-fabric simulations without network transport.

## Non-goals

- Offensive deployment tooling.
- Real-world intrusion automation.
- Obfuscation for concealment.
- Deceptive behavior against users or systems.
- Packet transmission, active probing, exploit delivery, credential interception, or persistence behaviors.

## Verification approach

- Unit tests verify that transport guards reject non-local endpoints.
- Puzzle error states are documented and marked as authored simulation states.
- Fixtures are synthetic and repository-local.
