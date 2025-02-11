
# Valk (WIP)

[Website](https://valk-lang.dev) | [Documentation](https://github.com/valk-lang/valk/blob/main/docs/docs.md) | [Roadmap](https://github.com/valk-lang/valk/blob/main/ROADMAP.md) | [Discord](https://discord.gg/RwEGqdSERA)

Valk is a programming language aimed to be fast & simple at the same time. It offers the best of all worlds. The simplicity of python with the performance of Rust. It has a new way of doing garbage collection which allows it to be much faster than what is currently available in the gc space. We also allow you to access memory directly so developers can invent their own types/structures. We try to bring back the joy in programming.

**Features**: Fastest GC ⚡, Coroutines, No undefined behaviour, Great package management, Generics, Fast compile times, Cross compiling, and more...

**Coroutines** are purely for concurrency. Threads can be used for parallelism.


## Install

TODO

## Basic example

```rust
// main.va
fn main() {
    println("Hello Valk! 🎉")
}
```

```sh
valk build main.valk -o ./main
./main
```

## Build from source (Linux / macOS / WSL)

macOS: `brew install llvm@15 && brew link llvm@15`

Ubuntu / Debian: `sudo apt-get install llvm-15 lld`

```bash
git clone https://github.com/valk-lang/valk.git
cd valk
make
```

## Supported platforms

| OS | Linux | Macos | Windows |
|--|--|--|--|
| x64 | ✅ | ✅ | ✅ |
| arm64 | ✔️ | ✅ | ❌ |

✅️ = Available & passes tests | ✔️ = Available, untested | ❌️ = Not available right now

## Benchmarks

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-bintree.png">
</p>
The binary object tree test revolves around creating large amount of objects in a tree structure, iterating over them and doing some calculations.
</div>

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-http.png">
</p></div>

## Why Valk over Rust, Go, Zig?

Valk offers a performance & simplicity mixture that these other languages cannot offer. Both Rust & Zig require you to think about alot of extra concepts. If you are trying to solve complex problems, you dont want more complexity on top of it.

As for performance, Valk and these 3 other languages will all relatively run at the same speed because they will mostly resolve to the same CPU instructions. But there's one big difference between them and that's how they manage memory. Currently we have a test where we compare the handling of millions of short/long-lived objects in Valk/Rust/Go. Valk seems to be ~30% faster than Rust and ~65% faster than Go. So not only do you get a simple language, you get very great performance as well. We cant compare it to Zig because how they manage memory is up to the developer.

Why is Valk so fast memory wise? We use memory pools and have an innovative gc algorithm. This algorithm has multiple benefits. E.g. We free short-lived objects using 0 cpu instructions. If you have a million short-lived objects, Rust would call `free()` a million times (we guess). Valk just resets a single pointer in the pool and all objects are freed at once.

## Language design facts

- Each thread handles it's own memory, but you can still share your variables with other threads. Even when your thread has ended, the memory will still be valid and automatically freed once other threads no longer use it.

- Valk does not force the user to use mutexes/locks for shared memory. Therefore the program can crash when you use multiple threads to modify the same data at the same time. Reading the same data with multiple threads is fine.

- Unlike other languages, our GC has no randomness. Every run is exactly the same as the run before to the last byte. So there are no fluctuations in cpu usage and memory usage. (Except when using shared memory over multiple threads)

## Contributions

Once we hit version 0.1.0, we want to look for people who can help with the standard library & 3rd party packages. If you want to contribute, just hop into the discord and post in general chat or send a private message to the discord owner.

## References

Binary tree benchmark code: [https://programming-language-benchmarks.vercel.app/problem/binarytrees](https://programming-language-benchmarks.vercel.app/problem/binarytrees)

