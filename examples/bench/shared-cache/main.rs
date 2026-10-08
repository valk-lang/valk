use hashbrown::HashMap;
use std::sync::{Arc, Mutex};
use std::thread;

struct Entry {
    key: u64,
    name: String,
    data: Vec<u64>,
}

fn entry(key: u64) -> Arc<Entry> {
    let mut data = Vec::with_capacity(16);
    for i in 0..16 {
        data.push(key * 31 + i);
    }
    Arc::new(Entry { key, name: format!("entry{}", key), data })
}

fn work(cache: &Mutex<HashMap<u64, Arc<Entry>>>, slots: u64, seed: u64, operations: u64) -> u64 {
    let mut total = 0u64;
    let mut r = seed;
    for _ in 0..operations {
        r = (r * 1103515245 + 12345) % 2147483648;
        let key = r % slots;
        if r % 10 == 0 {
            let fresh = entry(key);
            cache.lock().unwrap().insert(key, fresh);
        } else {
            let found = cache.lock().unwrap().get(&key).cloned();
            if let Some(found) = found {
                total += found.key + found.name.len() as u64;
                for value in &found.data {
                    total += value;
                }
            }
        }
    }
    total
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let slots: u64 = args.get(1).map_or(100000, |v| v.parse().unwrap());
    let operations: u64 = args.get(2).map_or(2000000, |v| v.parse().unwrap());

    let mut initial = HashMap::with_capacity(slots as usize);
    for i in 0..slots {
        initial.insert(i, entry(i));
    }
    let cache = Arc::new(Mutex::new(initial));

    let workers: Vec<_> = (0..4u64)
        .map(|t| {
            let cache = Arc::clone(&cache);
            thread::spawn(move || work(&cache, slots, t + 1, operations))
        })
        .collect();
    let total: u64 = workers.into_iter().map(|w| w.join().unwrap()).sum();
    println!("slots: {}, operations: {}, checksum: {}", slots, operations * 4, total);
}
