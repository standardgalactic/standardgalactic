#!/usr/bin/env python3
"""Estimate pi using a Monte Carlo simulation.

Usage:
    python experiment.py --samples 50000 --seed 42
"""

from __future__ import annotations

import argparse
import math
import random


def estimate_pi(samples: int, seed: int | None = None) -> tuple[float, int]:
    rng = random.Random(seed)
    hits = 0

    for _ in range(samples):
        x = rng.uniform(-1.0, 1.0)
        y = rng.uniform(-1.0, 1.0)
        if (x * x) + (y * y) <= 1.0:
            hits += 1

    return 4.0 * (hits / samples), hits


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Estimate pi with Monte Carlo sampling")
    parser.add_argument(
        "--samples",
        type=int,
        default=100_000,
        help="Number of random points to sample (default: 100000)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=None,
        help="Optional RNG seed for reproducible output",
    )
    args = parser.parse_args()

    if args.samples <= 0:
        parser.error("--samples must be a positive integer")

    return args


def main() -> None:
    args = parse_args()
    pi_estimate, hits = estimate_pi(args.samples, args.seed)
    abs_error = abs(math.pi - pi_estimate)

    print(f"samples={args.samples} hits={hits}")
    print(f"pi_estimate={pi_estimate:.8f}")
    print(f"abs_error={abs_error:.8f}")


if __name__ == "__main__":
    main()
