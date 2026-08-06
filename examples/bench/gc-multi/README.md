# GC hard suite

Stronger Valk vs Go comparison — dimensions where concurrent/tracing collectors
usually look better (or at least compete), beyond forced stable-heap collects.

| Scenario | What it stresses |
|----------|------------------|
| **mt-local churn** | N threads, no sharing — Valk per-thread heaps vs Go shared heap |
| **mt-shared publish** | Cross-thread object publish/replace — Valk shared STW vs Go concurrent GC |
| **natural pacing** | No forced GC; threshold-only / GOGC pacing, mixed retain |
| **fragmentation** | Mixed keep/drop rounds (retention patterns, holes) |
| **pause proxy** | Max batch mutator latency under alloc pressure (+ Go pause stats) |
| **live + natural churn** | Large live set + short-lived allocs without forced collects |

Sizes match between `main.valk` and `main.go`.

## Run

```bash
# Valk
./valk build examples/bench/gc-hard/main.valk -o /tmp/valk-gc-hard && /tmp/valk-gc-hard

# Go
cd examples/bench/gc-hard && go run main.go
```

Related lighter suite: `../gc` (forced collect rate, short-lived, free graph).

## Interpreting results

Go short-lived loops must force heap allocation (global sink). Without that,
escape analysis can make Go look unrealistically fast (`num_gc: 0`).

Rough expectations for a fair run:

| Scenario | Often favors |
|----------|----------------|
| mt-local, short-lived, stable forced collect | Valk |
| natural pacing, fragment, live+churn throughput | Valk (often) |
| max batch latency under alloc pressure | Valk (often) |
| **mt-shared publish/replace** | **Go** (shared concurrent heap) |
| tiny STW pause counters | Go (concurrent mark) |

A stronger claim needs both suites — not forced-collect rate alone.
