use std::sync::mpsc::{sync_channel, Receiver, SyncSender};
use std::sync::Arc;
use std::thread;

struct Message {
    id: u64,
    room: u64,
    body: String,
    mentions: Vec<u64>,
}

fn render(message: &Message) -> u64 {
    let mut sum = message.id + message.room;
    for byte in message.body.bytes() {
        sum += byte as u64;
    }
    for user in &message.mentions {
        sum += user;
    }
    sum
}

fn subscriber(inbox: Receiver<Arc<Message>>) -> u64 {
    let mut total = 0u64;
    for message in inbox {
        total += render(&message);
    }
    total
}

fn main() {
    let count: u64 = std::env::args().nth(1).map_or(500000, |v| v.parse().unwrap());

    let text = "The quick brown fox jumps over the lazy dog. ";
    let mut inboxes: Vec<SyncSender<Arc<Message>>> = Vec::new();
    let mut subscribers = Vec::new();
    for _ in 0..4 {
        let (sender, receiver) = sync_channel(1024);
        inboxes.push(sender);
        subscribers.push(thread::spawn(move || subscriber(receiver)));
    }

    for i in 0..count {
        let body = format!("{}{}{}message {}", text, text, text, i);
        let mentions = vec![i % 100, i % 1000];
        let message = Arc::new(Message { id: i, room: i % 10, body, mentions });
        for inbox in &inboxes {
            inbox.send(Arc::clone(&message)).unwrap();
        }
    }
    drop(inboxes);

    let total: u64 = subscribers.into_iter().map(|s| s.join().unwrap()).sum();
    println!("messages: {}, subscribers: 4, checksum: {}", count, total);
}
