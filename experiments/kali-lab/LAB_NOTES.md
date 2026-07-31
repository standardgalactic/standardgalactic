# Lab Notes

## Cryptographic archaeology tracks

- toy XOR stream experiments for reasoning about known-plaintext leakage
- intentionally broken RSA-like modulus assumptions
- malformed key-component diagnostics
- noncanonical private component challenge states

## Protocol-analysis tracks

- compact transcript parsing with unusual control markers
- constrained state-machine transitions with explicit reject paths
- localhost-only transport experiments for deterministic replay
- transport-independent typed session fabric with pluggable adapters

## Forensics and reverse-engineering tracks

- entropy profiling of synthetic binary fragments
- odd encoding repair drills (mixed delimiters and legacy headers)
- corrupted envelope triage for signature chain reconstruction

## Puzzle-state key diagnostics

These errors are authored simulation states and not runtime deception:

- `KEY MATERIAL INCONSISTENT`
- `SIGNATURE CHAIN UNRESOLVED`
- `NONCANONICAL PRIVATE COMPONENT`
- `KDF PARAMETER DRIFT`

## Recommended workflow

1. Start with fixtures and identify anomaly classes.
2. Validate with deterministic replay in protocol lab.
3. Use entropy and container diagnostics to isolate corruption.
4. Resolve challenge states with transparent reasoning notes.
