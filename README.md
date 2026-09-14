
<div align="center"><p>
    <img height="150" style="height: 150px" src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk.svg">
</p></div>

# Valk

[Website](https://valk-lang.dev) | [Documentation](https://valk-lang.dev/docs) | [Discord](https://discord.gg/RwEGqdSERA) | [Packages](https://vpkg.dev) | [vman](https://github.com/valk-lang/vman)

Valk is a programming language aimed to be fast & simple at the same time. The simplicity of Go with the performance of Rust. Valk is also the first programming language with a fully stateful garbage collector. Meaning no more mark/sweep mechanisms that cause performance problems. We aim to be a feature rich language with a large standard library.

**Features**: Fastest GC, Coroutines, Async IO, No undefined behaviour, Package management, Generics, Traits, Closures, Fast compile times, Cross compiling, Optional manual memory management, Integrate c libraries, and more...

To see what a stateful GC can do, see the [benchmarks](#benchmarks)

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
# valk main.valk
```

---

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
# optional: make test
```

## Supported platforms

| OS | Linux | Macos | Windows |
|--|--|--|--|
| x64 | ✅ | ✅ | ✅ |
| arm64 | ❌ | ✅ | ❌ |

✅️ = Available & passes tests | ❌️ = Not available right now

## Benchmarks

Valk 0.7.0, Go 1.27.1, Rust 1.97.1. Median of 3 runs after one warm-up, memory is peak RSS.

| Benchmark | Input | Valk time / memory | Go time / memory | Rust time / memory |
|---|---:|---:|---:|---:|
| binary-tree | 19 | 0.450s (53.4 MB) | 1.310s (57.4 MB) | 2.510s (66.3 MB) |
| binary-tree-multi | 19 | 0.190s (72.7 MB) | 0.500s (86.1 MB) | 0.690s (66.4 MB) |
| json | 2000000 | 0.730s (2.5 MB) | 2.100s (11.5 MB) | 0.420s (2.6 MB) |
| json-serde | sample, 50000 | 0.320s (151.6 MB) | 0.400s (228.3 MB) | 0.230s (119.2 MB) |
| lru | 1000, 11000000 | 0.640s (4.5 MB) | 0.750s (3.5 MB) | 0.430s (2.6 MB) |
| merkletrees | 18 | 0.400s (69.1 MB) | 1.120s (71.1 MB) | 1.620s (66.2 MB) |
| nsieve | 13 | 0.720s (80.3 MB) | 0.800s (141.8 MB) | 0.760s (80.5 MB) |
| spectral-norm | 5500 | 1.070s (2.5 MB) | 1.110s (5.6 MB) | 1.070s (2.5 MB) |
| spectral-norm-multi | 8000, 4 workers | 0.620s (5.7 MB) | 0.610s (9.7 MB) | 0.630s (2.8 MB) |

Code: [Link](examples/bench)

---

### GC benchmarks

| Scenario | Valk | Go | D | C# |
|---|---:|---:|---:|---:|
| short-lived alloc | 9 ms | 76 ms | 128 ms | 82 ms |
| stable-heap forced collects | 4 ms | 4195 ms | 1541 ms | 2851 ms |
| build long-lived chain | 49 ms | 67 ms | 144 ms | 201 ms |
| free long-lived chain | 62 ms | 65 ms | 9 ms | 13 ms |
| mutate live links | 9 ms | 8 ms | 10 ms | 12 ms |
| short-lived churn with large live set | 31 ms | 74 ms | 102 ms | 50 ms |
| tree churn | 72 ms | 119 ms | 269 ms | 120 ms |

Code: [Link](examples/bench/gc)

This benchmark runs different kinds of memory structures/lifetimes and 
looks how it affects the garbage collector.

The force collect benchmark is unrealistic but does reveal a factual difference
in overhead of the garbage collectors. As valk only needs to process modified
memory our GC has no problem with this.

---

### HTTP server benchmark

<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-http-dark.svg">
    <img alt="HTTP hello-world benchmark: Valk 6.46M, Rust hyper 5.07M, Go fasthttp 3.44M requests per second" src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-http.svg">
</picture>

Code: [Link](examples/bench/http)

## Why Valk over Rust, Go, Zig?

The main goal of Valk is that it's simple to write but it runs lightning fast. We dont want to manage memory or lifetimes. Developers already have to solve complex problems, we dont need to add more complexity on top of it.

So why not Go? It is a great language, Valk is just an alternative. Which one you find better is up to you. However, Valk is different than Go. Different, error handling, package management, coroutines, c-compatible, etc. If you don't like Go, you might like Valk.

Valk is also somewhat the only language without a mark/sweep GC. If you have experienced latency problems in other GC languages, you might want to try out Valk.

When not to use Valk:

- When you need very low-level control. E.g. custom assembly code / register access.

- When your program needs to run on niche infrastructure. We currently only support Linux x64, macOS x64/arm64 and Windows x64.

## Language design

- Our coroutines are stackful. Each one runs on its own 1 MB stack; `main` gets 8 MB.

- Coroutines are single threaded. A coroutine will always run on the same thread it started on.

- Each thread manages its own memory, so a local collection never blocks other threads. Objects can be published to other threads as `shared`; those are collected in a separate pass that runs when enough shared data has been published, not on a timer.

- The local GC has no timers or background threads. Collections happen at allocation thresholds, so a program behaves the same way every time you run it.

- We are a self hosted language with an embedded LLVM 22 backend. Pass `--clang` to compile the emitted textual IR with external clang instead. We depend on libc for system calls. We use the system linker on Linux and macOS, and lld when cross compiling or targeting Windows.

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
