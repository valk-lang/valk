# GC bench suite

Side-by-side microbenchmarks for Valk, Go, D, and C# garbage collectors.

| Scenario | What it measures |
|----------|------------------|
| **short-lived alloc** | Objects that die without escaping (Valk never-owned / pool reuse path) |
| **stable-heap forced collects** | Collection cost with a large live set and no mutations |
| **build long-lived chain** | Alloc + heap pointer writes building a big live graph |
| **free long-lived chain** | Drop root and reclaim a large owned graph |
| **mutate live links** | Repeated pointer rewrites on a live list (write barriers / dirty objects) |
| **short-lived churn with large live set** | Nursery/churn tax while a large live set stays rooted |
| **tree churn** | Allocate/discard trees with internal edges |

Sizes are matched across `main.valk`, `main.go`, `main.d`, and `main.cs`.

## Run

```bash
# Build and run all four optimized implementations (from repo root)
./examples/bench/run-gc.sh

# Run selected implementations
./examples/bench/run-gc.sh valk go

# Valk (from repo root)
./valk run examples/bench/gc/main.valk
# or
./valk build examples/bench/gc/main.valk -o /tmp/valk-gc-bench && /tmp/valk-gc-bench

# Go
go run examples/bench/gc/main.go
```

(If Go complains about modules: `cd examples/bench/gc && go run main.go`.)

For a less “forced GC” Go baseline you can leave GOGC alone (default).  
To compare forced-collection behavior more directly:

```bash
GOGC=off go run examples/bench/gc/main.go   # only explicit runtime.GC() collects
```

## Notes

- `mem_kb` is **not** defined identically: Valk reports thread pool usage, while the other runtimes report their currently managed/allocated heap. Use times/rates as the primary comparison. The runner additionally reports process peak RSS uniformly through GNU `time`.
- The D runner accepts LDC, DMD, or GDC. C# is built with the .NET SDK.
- Existing related benches: `../gc-overhead`, `../objects`, `../binary-tree`.
