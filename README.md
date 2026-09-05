
<div align="center"><p>
    <img height="150" style="height: 150px" src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk.svg">
</p></div>

# Valk

[Website](https://valk-lang.dev) | [Documentation](https://github.com/valk-lang/valk/blob/main/docs/docs.md) | [Discord](https://discord.gg/RwEGqdSERA) | [Packages](https://vpkg.dev) | [vman](https://github.com/valk-lang/vman)

Valk is a programming language aimed to be fast & simple at the same time. The simplicity of Go with the performance of Rust. Valk is also the first programming language with a fully stateful garbage collector. Meaning no more mark/sweep mechanisms that cause performance problems. We aim to be a feature rich language with a large standard library.

**Features**: Fastest GC, Coroutines, Async IO, No undefined behaviour, Package management, Generics, Traits, Closures, Fast compile times, Cross compiling, Optional manual memory mangement, Integrate c libraries, and more...

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

Valk 0.5.1, Go 1.27.1, Rust 1.97.1. Median of 3 runs after one warm-up, memory is peak RSS.

| Benchmark | Input | Valk time / memory | Go time / memory | Rust time / memory |
|---|---:|---:|---:|---:|
| binary-tree | 19 | 0.620s (55.3 MB) | 1.340s (58.2 MB) | 2.600s (66.3 MB) |
| binary-tree-multi | 19 | 0.230s (74.9 MB) | 0.510s (87.2 MB) | 0.670s (66.3 MB) |
| json | 2000000 | 0.970s (2.0 MB) | 2.610s (11.4 MB) | 0.430s (2.5 MB) |
| json-serde | sample, 50000 | 0.360s (134.7 MB) | 0.410s (228.0 MB) | 0.240s (119.3 MB) |
| lru | 1000, 11000000 | 0.660s (2.0 MB) | 0.760s (5.5 MB) | 0.450s (2.6 MB) |
| merkletrees | 18 | 0.520s (66.5 MB) | 1.170s (75.0 MB) | 1.680s (66.3 MB) |
| nsieve | 13 | 0.800s (79.9 MB) | 0.860s (141.9 MB) | 0.860s (80.6 MB) |
| spectral-norm | 5500 | 1.130s (2.1 MB) | 1.120s (5.6 MB) | 1.080s (2.5 MB) |
| spectral-norm-multi | 8000, 4 workers | 0.650s (3.7 MB) | 0.630s (9.7 MB) | 0.650s (2.8 MB) |

Code: [Link](examples/bench)

---

### GC benchmarks

| Scenario | Valk | Go | D | C# |
|---|---:|---:|---:|---:|
| short-lived alloc | 13 ms | 111 ms | 210 ms | 76 ms |
| stable-heap forced collects | 44 ms | 42103 ms | 27000 ms | 29093 ms |
| build long-lived chain | 43 ms | 71 ms | 185 ms | 209 ms |
| free long-lived chain | 18 ms | 62 ms | 3 ms | 13 ms |
| mutate live links | 10 ms | 8 ms | 11 ms | 12 ms |
| short-lived churn with large live set | 21 ms | 96 ms | 133 ms | 47 ms |
| tree churn | 51 ms | 194 ms | 277 ms | 121 ms |

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

- When your program needs to run on niche infrastructure. We currently only support: win/linux/mac for x86_64/arm64.

- Creating .dll/.so/.a/.lib files. (We will support this in the future)

## Language design

- Our co routines are stackful and use growing stacks

- Co routines are single threaded. A co-routine will always run on the same thread it started on.

- Each thread manages it's own memory. So we dont need to block other threads. You can share objects with other threads. Each time you do, the shared memory counter increases. At a certain point it will block other threads to free un-used shared objects. But we never block every X seconds like many other languages do.

- The local GC has no randomness. Every time you run a program it will use the exact same amount of memory and run at the exact same speed.

- We are a self hosted language with an embedded LLVM 22 backend. Pass `--clang` to compile the emitted textual IR with external clang instead. We depend on libc for system calls. We use the native linux & macos linker. For windows we use lld-link.

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
