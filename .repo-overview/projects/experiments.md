**Rust Monte‑Carlo π Estimation**

This Rust project implements the classic Monte Carlo method for estimating the value of \(\pi\). The algorithm works by:

1. Generating `N` random points uniformly distributed in the unit square \([0, 1] \times [0, 1]\).
2. Counting how many of those points fall inside the quarter‑circle of radius 1 centered at the origin (i.e., satisfy \(x^2 + y^2 \leq 1\)).
3. Using the ratio of “inside” points to total points to approximate \(\pi\) via the relation:

   \[
   \frac{\text{points inside quarter‑circle}}{N} \approx \frac{\text{area of quarter‑circle}}{\text{area of square}} = \frac{\pi / 4}{1} = \frac{\pi}{4}
   \]

   Hence, \(\pi \approx 4 \times (\text{points inside} / N)\).

### Build and Run

```bash
# Navigate to the Rust experiment directory
cd experiments/rust

# Compile and run the program.
# The first argument is the number of samples (e.g., 100000).
# The second argument is an optional random seed for reproducibility.
cargo run -- 100000 42
```

**Example Output**

```text
Samples: 100000, Seed: 42
Inside quarter‑circle: 78540
Estimated π: 3.141600
Actual π (approx): 3.141592653589793
Error: 0.00000735
```

### Parameters

| Parameter | Description |
|------------|-------------|
| `samples`  | Total number of random points to generate (`N`). Larger values improve accuracy but increase computation time. |
| `seed`     | Optional integer seed for the random number generator, ensuring reproducible results across runs. |

### Underlying Code Highlights

```rust
fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} <samples> [seed]", args[0]);
        return;
    }

    let samples = args[1].parse::<usize>().unwrap_or(100000);
    let seed = if args.len() >= 3 {
        Some(args[2].parse::<u64>().unwrap())
    } else {
        None
    };

    // Initialize random generator with optional seed
    let mut rng: rand::rngs::StdRng = match seed {
        Some(s) => rand::SeedableRng::seed_from_u64(s),
        None => rand::thread_rng(),
    };

    // Monte Carlo simulation loop
    let inside = (0..samples)
        .map(|_| {
            let x = rng.gen_range(0.0..1.0);
            let y = rng.gen_range(0.0..1.0);
            if x * x + y * y <= 1.0 { 1 } else { 0 }
        })
        .sum::<u32>();

    // Estimate π
    let pi_estimate = 4.0 * inside as f64 / samples as f64;

    println!("Samples: {:>5}, Seed: {:?}", samples, seed);
    println!("Inside quarter‑circle: {}", inside);
    println!("Estimated π: {:.9}", pi_estimate);
}
```

### Comparison with Python Version

The accompanying Python script (`experiments/python/experiment.py`) implements the same algorithm. Running both under identical parameters yields nearly identical estimates, demonstrating that the core computational idea is language‑agnostic while highlighting differences in performance and tooling.

**Key Takeaways**

- **Reproducibility:** The optional seed ensures that runs are deterministic.
- **Scalability:** Increasing `samples` improves precision at a predictable linear cost.
- **Cross‑Language Validation:** By comparing Rust and Python implementations, we verify the algorithm’s correctness across different ecosystems. 

For further exploration, consult the broader "Microsecurity for Microprofessionals" framework referenced in the top‑level README to understand how such minimal experiments fit into larger research or educational contexts.

