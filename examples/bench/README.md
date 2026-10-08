# Cross-language benchmarks

Run every benchmark in Valk, Go, and Rust:

```sh
./examples/bench/run.sh
```

The script builds optimized binaries, performs one unmeasured warm-up, then
reports the median wall time and median peak resident memory from three fresh
processes. Progress is written to stderr and the Markdown results table is
written to stdout.

Run selected benchmarks or change the sample count:

```sh
./examples/bench/run.sh --runs 5 binary-tree json-serde
```

Use `--list` to print the available benchmarks. The default inputs are chosen
to take roughly 0.5 to 2 seconds per run on a typical development machine. All
languages receive exactly the same input.

Both single-threaded and multithreaded variants of `binary-tree` and
`spectral-norm` are included. `binary-tree-multi` evaluates each reported tree
depth on a separate worker. The four-worker `spectral-norm-multi` variant uses
input `8000`, matching the programming-language-benchmarks workload.

The `json` benchmark measures dynamic JSON values, while `json-serde` uses the
larger file-oriented serialization workload. Both Go implementations use
`encoding/json/v2` with its default options.

The `shared-*` benchmarks measure data shared between four threads, each in the
way the language is normally written: `shared T`, `Lock[T]` and `sync.Channel`
in Valk, plain pointers, `sync.Mutex` and channels in Go, `Arc`, `Mutex` and
`std::sync::mpsc` in Rust (maps from `hashbrown`). Every program prints the same
checksum.

| Benchmark | What it does |
|---|---|
| `shared-read` | Threads look up random users in a shared 200k-entry map and allocate a small result per lookup |
| `shared-channel` | Four producer/consumer pairs pass objects (a string and an array) over bounded channels |
| `shared-lock` | Threads increment counters in one map behind one lock: maximum contention |
| `shared-cache` | Threads read (90%) and replace (10%) entries of a locked map; readers use the entry after unlocking |
| `shared-broadcast` | One producer sends every message to four subscriber channels, as a chat server does |

```sh
./examples/bench/run.sh shared-read shared-channel shared-lock shared-cache shared-broadcast
```

Valk 0.7.11 (dev), Go 1.27.1, Rust 1.97.1 on 12 cores. Median of 5 runs after one
warm-up, memory is peak RSS.

| Benchmark | Input | Valk time / memory | Go time / memory | Rust time / memory |
|---|---:|---:|---:|---:|
| shared-read | 200k users, 4x5M lookups | 0.950s (93.6 MB) | 0.430s (94.7 MB) | 0.820s (72.1 MB) |
| shared-channel | 4 pairs, 4x1M messages | 0.370s (11.2 MB) | 0.160s (13.6 MB) | 0.520s (3.1 MB) |
| shared-lock | 10k keys, 4x2M updates | 0.640s (4.0 MB) | 0.260s (7.5 MB) | 0.690s (3.7 MB) |
| shared-cache | 100k slots, 4x2M ops | 1.110s (81.2 MB) | 0.580s (51.1 MB) | 1.150s (29.1 MB) |
| shared-broadcast | 500k messages, 4 subscribers | 0.320s (8.2 MB) | 0.120s (12.1 MB) | 1.070s (3.0 MB) |

Go's scheduler moves goroutines between a few threads without system calls, which
helps the lock and hand-off heavy cases. Valk and Rust wake real threads.

Requirements are the Valk compiler at the repository root, Go 1.27+, Rust with
Cargo, and GNU `/usr/bin/time`.

The larger seven-scenario garbage-collector comparison has its own runner for
Valk, Go, D, and C#:

```sh
./examples/bench/run-gc.sh
```
