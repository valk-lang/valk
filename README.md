
<div align="center"><p>
    <img height="150" style="height: 150px" src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk.svg">
</p></div>

# Valk (beta)

[Website](https://valk-lang.dev) | [Documentation](https://github.com/valk-lang/valk/blob/main/docs/docs.md) | [Roadmap](https://github.com/valk-lang/valk/blob/main/ROADMAP.md) | [Discord](https://discord.gg/RwEGqdSERA)

Valk is a programming language aimed to be fast & simple at the same time. The simplicity of Go with the performance of Rust. Valk is also the first programming language with a persistent garbage collector. Meaning no more mark/sweep mechanisms that cause performance problems. We aim to be a feature rich language with a large standard library.

**Features**: Fastest GC, Coroutines, No undefined behaviour, Package management, Generics, Traits, Closures, Fast compile times, Cross compiling, Optional manual memory mangement, Integrate c libraries, and more...

To see what a persistent GC can do, see the [benchmarks](#benchmarks)

## Install

Linux / MacOS

```
curl -s https://valk-lang.dev/install.sh | bash -s latest
```

Windows: Download from our website and unzip it into a directory. Optionally: Add the directory to your PATH.


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

macOS: `brew install llvm@15 && brew link llvm@15`

Ubuntu / Debian: `sudo apt-get install llvm-15 lld`

```bash
git clone https://github.com/valk-lang/valk.git
cd valk
vpkg use 0.0.1
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

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-gc.png">
</p>
</div>

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-bintree.png">
</p>
The binary object tree test revolves around creating large amount of short-/long-lived objects, iterating over them and doing some calculations.
</div>

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-http.png">
</p></div>

## Why Valk over Rust, Go, Zig?

Valk offers a performance & simplicity mixture that these other languages cannot offer. Both Rust & Zig require you to think about alot of extra concepts. If you are trying to solve complex problems, you dont want more complexity on top of it.

As for performance, Valk and these 3 other languages will all relatively run at the same speed because they will mostly resolve to the same CPU instructions. But there's one big difference between them and that's how they manage memory. Currently we have a test where we compare the handling of millions of short/long-lived objects in Valk/Rust/Go. Valk seems to be ~30% faster than Rust and ~65% faster than Go. So not only do you get a simple language, you get very great performance as well. We cant compare it to Zig because how they manage memory is up to the developer.

Why is Valk so fast memory wise? We use memory pools and have an innovative gc algorithm. This algorithm has multiple benefits. E.g. We free short-lived objects using 0 cpu instructions. If you have a million short-lived objects, Rust would call `free()` a million times (we guess). Valk just resets a single pointer in the pool and all objects are freed at once.

As for long-lived objects, this is where Valk also shines because our GC is completely stateful. We dont need to mark/sweep everything to see which objects are no longer used. We track the changes instead. This is also why we get such performance win over Go. When long-lived objects exist, Go has to mark/sweep them, we dont.

## Language design

- Each thread handles it's own memory, but you can still share your variables with other threads. Even when your thread has ended, the memory will still be valid and automatically freed once other threads no longer use it.

- Unlike other languages, our GC has no randomness. Every run is exactly the same as the run before to the last byte. So there are no fluctuations in cpu usage and memory usage. (Except when using shared memory over multiple threads)

- Reading shared data from multiple threads is safe. Mutating shared data is not. The developer is responsible for using mutexes/atomics.

- Coroutines are single threaded. So mutating data over multiple coroutines is safe.

## Contributions

Once we hit version 0.1.0, we want to look for people who can help with the standard library & 3rd party packages. If you want to contribute, just hop into the discord and post in general chat or send a private message to the discord owner.

## References

Binary tree benchmark code: [https://programming-language-benchmarks.vercel.app/problem/binarytrees](https://programming-language-benchmarks.vercel.app/problem/binarytrees)

