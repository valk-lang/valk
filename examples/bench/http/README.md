# HTTP hello-world benchmark

Three servers answering `Hello, World!` on loopback:

| File       | Server              | Port |
|------------|---------------------|------|
| `main.valk`| valk `http.Server` with a fast handler | 9000 |
| `main.rs`  | Rust hyper 1.x on tokio | 9001 |
| `main.go`  | Go fasthttp         | 9002 |

Build instructions for the Go and Rust servers are in the file headers.
The valk server:

    valk build main.valk --release -o bench-http && ./bench-http

Load with wrk, 900 keep-alive connections and 16 pipelined requests per
round trip (`pipe.lua` concatenates `depth` copies of the request):

    wrk --latency -d 5 -c 900 -t 8 --timeout 8 http://127.0.0.1:9000/ -s pipe.lua -- 16

For a fair per-core comparison give every server the same number of worker
threads (the last argument of `http.serve_fast` in valk, `worker_threads = N` for tokio, `GOMAXPROCS=N`
for Go) and pin the servers and wrk to disjoint cores with `taskset`.
