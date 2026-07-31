use std::f64::consts::PI;

fn estimate_pi(samples: u64, seed: u64) -> (f64, u64) {
    let mut state = seed;
    let mut hits: u64 = 0;

    for _ in 0..samples {
        let x = next_f64(&mut state) * 2.0 - 1.0;
        let y = next_f64(&mut state) * 2.0 - 1.0;
        if (x * x) + (y * y) <= 1.0 {
            hits += 1;
        }
    }

    (4.0 * (hits as f64 / samples as f64), hits)
}

fn next_u64(state: &mut u64) -> u64 {
    // LCG parameters from Numerical Recipes.
    *state = state
        .wrapping_mul(6364136223846793005)
        .wrapping_add(1442695040888963407);
    *state
}

fn next_f64(state: &mut u64) -> f64 {
    let bits = next_u64(state) >> 11;
    bits as f64 / ((1u64 << 53) as f64)
}

fn parse_arg<T: std::str::FromStr>(args: &[String], index: usize, default: T) -> T {
    args.get(index)
        .and_then(|s| s.parse::<T>().ok())
        .unwrap_or(default)
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let samples: u64 = parse_arg(&args, 1, 100_000);
    let seed: u64 = parse_arg(&args, 2, 42);

    if samples == 0 {
        eprintln!("samples must be greater than 0");
        std::process::exit(1);
    }

    let (pi_estimate, hits) = estimate_pi(samples, seed);
    let abs_error = (PI - pi_estimate).abs();

    println!("samples={} hits={}", samples, hits);
    println!("pi_estimate={:.8}", pi_estimate);
    println!("abs_error={:.8}", abs_error);
}
