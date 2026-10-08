use std::sync::mpsc::{sync_channel, Receiver, SyncSender};
use std::thread;

struct Message {
    id: u64,
    text: String,
    values: Vec<u64>,
}

fn produce(channel: SyncSender<Box<Message>>, first: u64, count: u64) {
    for i in 0..count {
        let id = first + i;
        let mut values = Vec::with_capacity(8);
        for j in 0..8 {
            values.push(id + j);
        }
        channel
            .send(Box::new(Message { id, text: id.to_string(), values }))
            .unwrap();
    }
}

fn consume(channel: Receiver<Box<Message>>) -> u64 {
    let mut total = 0u64;
    for message in channel {
        total += message.id + message.text.len() as u64;
        for value in &message.values {
            total += value;
        }
    }
    total
}

fn main() {
    let count: u64 = std::env::args().nth(1).map_or(1000000, |v| v.parse().unwrap());

    let mut producers = Vec::new();
    let mut consumers = Vec::new();
    for p in 0..4u64 {
        let (sender, receiver) = sync_channel(1024);
        producers.push(thread::spawn(move || produce(sender, p * count, count)));
        consumers.push(thread::spawn(move || consume(receiver)));
    }
    for producer in producers {
        producer.join().unwrap();
    }
    let total: u64 = consumers.into_iter().map(|c| c.join().unwrap()).sum();
    println!("messages: {}, checksum: {}", count * 4, total);
}
