use hashbrown::HashMap;
use std::sync::Arc;
use std::thread;

struct User {
    id: u64,
    name: String,
    tags: Vec<String>,
    score: u64,
}

#[allow(dead_code)]
struct Hit {
    id: u64,
    score: u64,
}

fn build(count: u64) -> HashMap<String, User> {
    let mut users = HashMap::with_capacity(count as usize);
    for i in 0..count {
        let name = format!("user{}", i);
        users.insert(
            name.clone(),
            User {
                id: i,
                name,
                tags: vec![format!("tag{}", i % 7), format!("tag{}", i % 13)],
                score: i * 7 % 1000,
            },
        );
    }
    users
}

fn names(count: u64) -> Vec<String> {
    (0..count).map(|i| format!("user{}", i)).collect()
}

fn work(users: &HashMap<String, User>, keys: &[String], seed: u64, lookups: u64) -> u64 {
    let mut total = 0u64;
    let mut hits: Vec<Box<Hit>> = Vec::with_capacity(1000);
    let mut r = seed;
    for _ in 0..lookups {
        r = (r * 1103515245 + 12345) % 2147483648;
        let user = &users[&keys[(r % keys.len() as u64) as usize]];
        total += user.score + user.name.len() as u64 + user.tags.len() as u64;
        hits.push(Box::new(Hit { id: user.id, score: user.score }));
        if hits.len() == 1000 {
            hits.clear();
        }
    }
    std::hint::black_box(&hits);
    total
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let count: u64 = args.get(1).map_or(200000, |v| v.parse().unwrap());
    let lookups: u64 = args.get(2).map_or(5000000, |v| v.parse().unwrap());

    let users = Arc::new(build(count));
    let keys = Arc::new(names(count));

    let workers: Vec<_> = (0..4u64)
        .map(|t| {
            let users = Arc::clone(&users);
            let keys = Arc::clone(&keys);
            thread::spawn(move || work(&users, &keys, t + 1, lookups))
        })
        .collect();
    let total: u64 = workers.into_iter().map(|w| w.join().unwrap()).sum();
    println!("users: {}, lookups: {}, checksum: {}", count, lookups * 4, total);
}
