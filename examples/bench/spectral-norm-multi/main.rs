use std::env;
use std::thread;

fn eval_a(i: usize, j: usize) -> f64 {
    let ij = i + j;
    (ij * (ij + 1) / 2 + i + 1) as f64
}

fn multiply_range(input: &[f64], start: usize, end: usize, transpose: bool) -> Vec<f64> {
    let mut output = Vec::with_capacity(end - start);
    for i in start..end {
        let mut sum = 0.0;
        for (j, value) in input.iter().enumerate() {
            if transpose {
                sum += value / eval_a(j, i);
            } else {
                sum += value / eval_a(i, j);
            }
        }
        output.push(sum);
    }
    output
}

fn multiply(input: &[f64], transpose: bool, workers: usize) -> Vec<f64> {
    let chunk_size = input.len().div_ceil(workers);
    thread::scope(|scope| {
        let mut handles = Vec::with_capacity(workers);
        for worker in 0..workers {
            let start = worker * chunk_size;
            if start >= input.len() {
                break;
            }
            let end = (start + chunk_size).min(input.len());
            handles.push((
                start,
                scope.spawn(move || multiply_range(input, start, end, transpose)),
            ));
        }

        let mut output = vec![0.0; input.len()];
        for (start, handle) in handles {
            let values = handle.join().expect("spectral-norm worker panicked");
            output[start..start + values.len()].copy_from_slice(&values);
        }
        output
    })
}

fn multiply_at_a(input: &[f64], workers: usize) -> Vec<f64> {
    let temporary = multiply(input, false, workers);
    multiply(&temporary, true, workers)
}

fn positive_arg(index: usize, fallback: usize) -> usize {
    env::args()
        .nth(index)
        .map(|value| value.parse().expect("arguments must be positive integers"))
        .unwrap_or(fallback)
}

fn main() {
    let n = positive_arg(1, 8000);
    let workers = positive_arg(2, 4).min(n);
    assert!(n > 0 && workers > 0, "arguments must be positive integers");

    let mut u = vec![1.0; n];
    let mut v = Vec::new();
    for _ in 0..10 {
        v = multiply_at_a(&u, workers);
        u = multiply_at_a(&v, workers);
    }

    let (mut uv, mut vv) = (0.0, 0.0);
    for (u_value, v_value) in u.iter().zip(&v) {
        uv += u_value * v_value;
        vv += v_value * v_value;
    }
    println!("{:.9}", f64::sqrt(uv / vv));
}
