use hashbrown::HashMap;
use std::sync::{Arc, Mutex};
use std::thread;

fn words(count: u64) -> Vec<String> {
    (0..count).map(|i| format!("word{}", i)).collect()
}

fn work(counts: &Mutex<HashMap<String, u64>>, keys: &[String], seed: u64, updates: u64) {
    let mut r = seed;
    for _ in 0..updates {
        r = (r * 1103515245 + 12345) % 2147483648;
        let key = &keys[(r % keys.len() as u64) as usize];
        let mut map = counts.lock().unwrap();
        match map.get_mut(key) {
            Some(value) => *value += 1,
            None => {
                map.insert(key.clone(), 1);
            }
        }
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let count: u64 = args.get(1).map_or(10000, |v| v.parse().unwrap());
    let updates: u64 = args.get(2).map_or(2000000, |v| v.parse().unwrap());

    let keys = Arc::new(words(count));
    let counts = Arc::new(Mutex::new(HashMap::with_capacity(count as usize)));

    let workers: Vec<_> = (0..4u64)
        .map(|t| {
            let counts = Arc::clone(&counts);
            let keys = Arc::clone(&keys);
            thread::spawn(move || work(&counts, &keys, t + 1, updates))
        })
        .collect();
    for worker in workers {
        worker.join().unwrap();
    }

    let map = counts.lock().unwrap();
    let total: u64 = map.values().sum();
    let most = map.values().copied().max().unwrap_or(0);
    println!("keys: {}, updates: {}, most: {}", count, total, most);
}
