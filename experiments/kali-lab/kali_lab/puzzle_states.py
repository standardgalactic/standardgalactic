from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class PuzzleState:
    code: str
    reason: str
    simulated: bool = True


KEY_MATERIAL_INCONSISTENT = PuzzleState(
    code="KEY MATERIAL INCONSISTENT",
    reason="Authored vector where public and private parameters were intentionally mismatched.",
)

SIGNATURE_CHAIN_UNRESOLVED = PuzzleState(
    code="SIGNATURE CHAIN UNRESOLVED",
    reason="Synthetic envelope omits an intermediate certificate link.",
)

NONCANONICAL_PRIVATE_COMPONENT = PuzzleState(
    code="NONCANONICAL PRIVATE COMPONENT",
    reason="Fixture stores private scalar in noncanonical representation.",
)

KDF_PARAMETER_DRIFT = PuzzleState(
    code="KDF PARAMETER DRIFT",
    reason="Challenge vector rotates KDF rounds to trigger diagnostic review.",
)


def all_puzzle_states() -> list[PuzzleState]:
    return [
        KEY_MATERIAL_INCONSISTENT,
        SIGNATURE_CHAIN_UNRESOLVED,
        NONCANONICAL_PRIVATE_COMPONENT,
        KDF_PARAMETER_DRIFT,
    ]
