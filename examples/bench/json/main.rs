use serde_json::Value;
use std::env;

const SOURCE: &str = r#"{"name":"Alice","age":30,"email":"alice@example.com"}"#;

fn parse_amount() -> usize {
    env::args()
        .nth(1)
        .map(|value| value.parse().expect("amount must be a positive integer"))
        .unwrap_or(2_000_000)
}

fn main() {
    let amount = parse_amount();
    assert!(amount > 0, "amount must be a positive integer");

    let mut document = Value::Null;
    for _ in 0..amount {
        document = serde_json::from_str(SOURCE).expect("invalid JSON");
    }

    let mut encoded = Vec::new();
    for _ in 0..amount {
        encoded = serde_json::to_vec(&document).expect("failed to encode JSON");
    }

    println!(
        "{}|{}|{}",
        document["name"].as_str().expect("missing name"),
        document["age"].as_i64().expect("missing age"),
        document["email"].as_str().expect("missing email")
    );
    println!("{}", encoded.len());
}
