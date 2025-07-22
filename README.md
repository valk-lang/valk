
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
curl -s https://valk-lang.dev/install.sh | bash
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

Rust: Too much complexity in our opinion. It's not fun if you are already trying to solve complex problems.

Zig: Manual memory management. Which we can respect, but it's not something you want to do always for every project. And even if you manage it manually, we think Valk will still out perform your custom memory management in large projects.

Go: It's nice, but it also has alot wrong with it. No thread local globals, nil crashes, dead locks, it's package management, etc. etc. Valk tries to fix these pain-points. We also aim to be faster than Go.

When not to use Valk:

- Creating .dll/.so files. We currently dont even support it (but we will).

- When you need 100% control. Like if your program needs to change specific CPU register values.

- When your program needs to run on niche infrastructure. We currently only do: win/linux/mac with x64/arm64.

## Language design

- Co routines are semi-stackful. We run the co-routines on the main stack and if it blocks, we copy it to a temporary buffer. This way we can keep memory usage low. And yes, it's fast.

- Each thread manages it's own memory. So we dont need to block other threads. You can share objects with other threads. Each time you do, the shared memory counter increases. At a certain point it will block other threads to free un-used shared objects. But we never block every X seconds like other languages do.

- The local GC has no randomness. Every time you run a program it will use the exact same amount of memory and run at the exact same speed.

- Co routines are single threaded. We dont do task-stealing.

## Contributions

Once we hit version 0.1.0, we want to look for people who can help with the standard library & 3rd party packages. If you want to contribute, just hop into the discord and post in general chat or send a private message to the discord owner.

## References

Binary tree benchmark code: [https://programming-language-benchmarks.vercel.app/problem/binarytrees](https://programming-language-benchmarks.vercel.app/problem/binarytrees)

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valko-circle.png">
</p>
</div>
