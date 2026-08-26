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

Requirements are the Valk compiler at the repository root, Go, Rust with
Cargo, and GNU `/usr/bin/time`.

The larger seven-scenario garbage-collector comparison has its own runner for
Valk, Go, D, and C#:

```sh
./examples/bench/run-gc.sh
```
