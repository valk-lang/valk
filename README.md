
<div align="center"><p>
    <img height="150" style="height: 150px" src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk.svg">
</p></div>

# Valk

[Website](https://valk-lang.dev) | [Documentation](https://valk-lang.dev/docs) | [Discord](https://discord.gg/RwEGqdSERA) | [Packages](https://vpkg.dev) | [vman](https://github.com/valk-lang/vman)

Valk is a programming language aimed to be fast & simple at the same time. The simplicity of Go with the performance of Rust. We aim to be a feature rich language with a large standard library.

**Features**: Stateful GC, Coroutines, Async IO, No undefined behaviour, Package management, Generics, Traits, Closures, Fast compile times, Cross compiling, Optional manual memory management, Integrate c libraries, and more...

Language performance: [benchmarks](#benchmarks)

Extensions: [vscode](https://marketplace.visualstudio.com/items?itemName=valk-lang.valk) | [vim](https://github.com/valk-lang/valk-vim)

## Install

Linux / MacOS / WSL

```
curl -sSL https://valk-lang.dev/install.sh | bash
```

Windows (powershell)

```
irm https://valk-lang.dev/install.ps1 | iex
```


## Basic example

```rust
// main.valk
fn main() {
    println("Hello Valk! 🎉")
}
```

```sh
valk build main.valk -o ./main
./main
# Or to quickly build & run a script:
# valk run main.valk
```

## Project stage

<picture>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/roadmap.png">
</picture>

## Build from source (Linux / macOS / WSL)

valk/vman: `curl -sSL https://valk-lang.dev/install.sh | bash`

The compiler embeds LLVM 22 and uses it to generate object files.

Ubuntu / Debian: `sudo apt-get install lld`

```bash
git clone https://github.com/valk-lang/valk.git
cd valk
vman use
make toolchains
make
# optional: ./valk make test
```

`./valk ls` lists what the project declares: `test`, the test suites, `docs`,
`install` and `uninstall`.

## Supported platforms

| OS | Linux | Macos | Windows |
|--|--|--|--|
| x64 | ✅ | ✅ | ✅ |
| arm64 | ✅ | ✅ | ❌ |

✅️ = Available & passes tests | ❌️ = Not available right now

## Benchmarks

Valk 0.7.11, Go 1.27.1, Rust 1.97.1 on an AMD Ryzen 5 7600X (6 cores, 12 threads). Median of 3 runs after one warm-up, memory is peak RSS.

| Benchmark | Input | Valk time / memory | Go time / memory | Rust time / memory |
|---|---:|---:|---:|---:|
| binary-tree | 19 | 0.500s (57.6 MB) | 1.340s (58.1 MB) | 2.500s (66.3 MB) |
| binary-tree-multi | 19 | 0.310s (76.7 MB) | 0.510s (86.3 MB) | 0.680s (66.4 MB) |
| json | 2000000 | 0.430s (4.9 MB) | 2.100s (11.5 MB) | 0.420s (2.5 MB) |
| json-serde | sample, 50000 | 0.200s (155.7 MB) | 0.310s (215.1 MB) | 0.230s (119.2 MB) |
| lru | 1000, 11000000 | 0.360s (4.6 MB) | 0.770s (5.5 MB) | 0.440s (2.6 MB) |
| merkletrees | 18 | 0.490s (68.4 MB) | 1.210s (70.8 MB) | 1.620s (66.3 MB) |
| nsieve | 13 | 0.730s (82.1 MB) | 0.830s (141.9 MB) | 0.850s (80.5 MB) |
| spectral-norm | 5500 | 1.100s (2.4 MB) | 1.120s (5.6 MB) | 1.080s (2.6 MB) |
| spectral-norm-multi | 8000, 4 workers | 0.630s (7.0 MB) | 0.640s (11.7 MB) | 0.640s (2.8 MB) |

Code: [Link](examples/bench)

---

### GC benchmarks

Valk 0.7.11, Go 1.27.1, LDC 1.43.0, .NET 10.0.112. Median of 3 runs.

| Scenario | Valk | Go | D | C# |
|---|---:|---:|---:|---:|
| short-lived alloc | 8 ms | 74 ms | 130 ms | 77 ms |
| stable-heap forced collects | 0 ms | 4187 ms | 2535 ms | 2909 ms |
| build long-lived chain | 50 ms | 58 ms | 132 ms | 209 ms |
| free long-lived chain | 25 ms | 67 ms | 2 ms | 13 ms |
| mutate live links | 9 ms | 7 ms | 10 ms | 12 ms |
| short-lived churn with large live set | 4 ms | 77 ms | 87 ms | 48 ms |
| tree churn | 39 ms | 123 ms | 249 ms | 121 ms |

Code: [Link](examples/bench/gc)

This benchmark runs different kinds of memory structures/lifetimes and 
looks how it affects the garbage collector.

The force collect benchmark is unrealistic but does reveal a factual difference
in overhead of the garbage collectors. As valk only needs to process modified
memory our GC has no problem with this.

---

### HTTP server benchmark

HTTP hello world. Higher requests per second is better. Every server uses all 12 hardware
threads (its default); wrk runs on the same machine with 8 threads, 900 connections and 16
pipelined requests. Median of 3 runs of 5 seconds.

| Language | Library | Requests per second |
|---|---|---:|
| Valk 0.7.11 | http | 10,215,940 |
| Rust 1.97.1 | hyper 1.11 on tokio 1.53 | 8,474,162 |
| Go 1.27.1 | fasthttp 1.73 | 6,034,080 |

Code: [Link](examples/bench/http)

## Why Valk over Rust, Go, Zig?

The main goal of Valk is that it's simple to write but it runs lightning fast. We dont want to manage memory or lifetimes. Developers already have to solve complex problems, we dont need to add more complexity on top of it.

So why not Go? It is a great language, Valk is just an alternative. Which one you find better is up to you. However, Valk is different than Go. Different, error handling, package management, coroutines, c-compatible, etc. If you don't like Go, you might like Valk.

Valk is also somewhat the only language without a mark/sweep GC. If you have experienced latency problems in other GC languages, you might want to try out Valk.

When not to use Valk:

- When you need very low-level control. E.g. custom assembly code / register access.

- When your program needs to run on niche infrastructure. We currently only support Linux x64/arm64, macOS x64/arm64 and Windows x64.

## Language design

- Our coroutines are stackful. They start small 4-32KB and grow automatically when using more stack space.

- Coroutines are single threaded. A coroutine will always run on the same thread it started on.

- Each thread manages its own memory, so a local collection never blocks other threads. Data can be shared with other threads, but that data will be tagged and is then handled by a slower cross-thread GC.

- The local GC has no timers or background threads. Collections happen at allocation thresholds, so a program behaves the same way every time you run it.

- We are a self hosted language with an embedded LLVM 22 backend. We depend on libc for system calls. Released compilers link with lld built into them, so no separate linker is needed; native macOS builds use Apple's linker.

- How to trust a self hosted compiler? You can compile the valk source with --ir to a single IR file. Then you can compile that IR file with clang to create your new valk compiler and at that point you know there is no hidden code inside the compiler.

## Contributions

The most helpful thing you can do is to create 3rd party packages.

If you want to work on the language itself, just hop on our discord and discuss with us what you want to change.

Either way, you should join our [discord](https://discord.gg/RwEGqdSERA) 😊 Everyone is welcome. The more people, the better.

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valko-circle.png">
</p>
</div>
