use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Deserialize, Serialize)]
struct GeoData {
    #[serde(rename = "type")]
    kind: String,
    features: Vec<Feature>,
}

#[derive(Deserialize, Serialize)]
struct Feature {
    #[serde(rename = "type")]
    kind: String,
    properties: Properties,
    geometry: Geometry,
}

#[derive(Deserialize, Serialize)]
struct Properties {
    name: String,
}

#[derive(Deserialize, Serialize)]
struct Geometry {
    #[serde(rename = "type")]
    kind: String,
    coordinates: Vec<Vec<Vec<f64>>>,
}

fn main() -> anyhow::Result<()> {
    let file_name = std::env::args_os()
        .nth(1)
        .and_then(|s| s.into_string().ok())
        .unwrap_or("sample".to_string());
    let n = std::env::args_os()
        .nth(2)
        .and_then(|s| s.into_string().ok())
        .and_then(|s| s.parse().ok())
        .unwrap_or(10);
    let json_str = fs::read_to_string(format!("{}.json", file_name))?;
    let document: GeoData = serde_json::from_str(&json_str)?;
    print_hash(serde_json::to_vec(&document)?);
    let mut array = Vec::with_capacity(n);
    for _ in 0..n {
        array.push(serde_json::from_str::<GeoData>(&json_str)?);
    }
    print_hash(serde_json::to_vec(&array)?);
    Ok(())
}

fn print_hash(bytes: impl AsRef<[u8]>) {
    let digest = md5::compute(&bytes);
    println!("{:x}", digest);
}
