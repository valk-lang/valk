// Rust: hyper 1.x hello-world server on tokio, port 9001
//
// Cargo.toml:
//   [dependencies]
//   http-body-util = "0.1"
//   hyper = { version = "1", features = ["http1", "server"] }
//   hyper-util = { version = "0.1", features = ["tokio"] }
//   tokio = { version = "1", features = ["rt-multi-thread", "net", "macros"] }
//   [profile.release]
//   lto = "thin"
//   codegen-units = 1
//   panic = "abort"
//
// Add `worker_threads = N` to the tokio::main attribute to fix the thread count.

use std::convert::Infallible;

use http_body_util::Full;
use hyper::{
    body::{Bytes, Incoming},
    server::conn::http1,
    service::service_fn,
    Request, Response,
};
use hyper_util::rt::TokioIo;
use tokio::net::TcpListener;

static BODY: &[u8] = b"Hello, World!";

async fn handle(_: Request<Incoming>) -> Result<Response<Full<Bytes>>, Infallible> {
    Ok(Response::new(Full::new(Bytes::from_static(BODY))))
}

#[tokio::main(flavor = "multi_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let listener = TcpListener::bind("127.0.0.1:9001").await?;

    loop {
        let (stream, _) = listener.accept().await?;
        stream.set_nodelay(true)?;

        tokio::spawn(async move {
            let io = TokioIo::new(stream);
            let mut http = http1::Builder::new();
            http.keep_alive(true).pipeline_flush(true).writev(true);
            let _ = http.serve_connection(io, service_fn(handle)).await;
        });
    }
}
