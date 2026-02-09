
<div align="center"><p>
    <img height="150" style="height: 150px" src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk.svg">
</p></div>

# Valk (beta)

[Website](https://valk-lang.dev) | [Documentation](https://github.com/valk-lang/valk/blob/main/docs/docs.md) | [Roadmap](https://github.com/valk-lang/valk/blob/main/ROADMAP.md) | [Discord](https://discord.gg/RwEGqdSERA)

Valk is a programming language aimed to be fast & simple at the same time. The simplicity of Go with the performance of Rust. Valk is also the first programming language with a fully stateful garbage collector. Meaning no more mark/sweep mechanisms that cause performance problems. We aim to be a feature rich language with a large standard library.

**Features**: Fastest GC, Coroutines, No undefined behaviour, Package management, Generics, Traits, Closures, Fast compile times, Cross compiling, Optional manual memory mangement, Integrate c libraries, and more...

To see what a stateful GC can do, see the [benchmarks](#benchmarks)

Extensions: [vscode](https://marketplace.visualstudio.com/items?itemName=valk-lang.valk) | [vim](https://github.com/valk-lang/valk-vim)

## Install

Linux / MacOS / WSL

```
curl -s https://valk-lang.dev/install.sh | bash
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

valk/vman: `curl -s https://valk-lang.dev/install.sh | bash`

macOS: `brew install llvm@15 && brew link llvm@15`

Ubuntu / Debian: `sudo apt-get install llvm-15 lld`

```bash
git clone https://github.com/valk-lang/valk.git
cd valk
vman use
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

Code: [Link](examples/bench/gc-overhead)

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-bintree.png">
</p>
</div>

The binary object tree test revolves around creating large amount of short-/long-lived objects, iterating over them and doing some calculations.

Code: [Link](examples/bench/binary-tree)

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valk-http.png">
</p></div>

Code: [Link](examples/bench/http)

---

### Object creation statistics

Creating 10 million objects of size 8:

|  | Create short lived | Create long lived | Process memory usage |
|--|--|--|--|
| Valk | 31ms | 128ms | 160 MB |
| Go | 115ms | 216ms | 591 MB |

Code: [Link](examples/bench/objects)


## Why Valk over Rust, Go, Zig?

`Rust`: Too much complexity. Having to deal with complex coding concepts is not great if we are already trying to solve complex problems. Also: Slow compile times and their way of doing async.

`Zig`: Manual memory management. It's not something you want to do in every project. The less things you have to manage/think about, the easier it is to manage your code. There are also philosophical differences between zig and valk. E.g. No hidden allocations. Which is great, but it does come with down sides that you will need to deal with every time.

`Go`: Great language, but there are alot of things we dont like. Nil checking/crashes, dead locks, it's package management, no thread local storage and more.

`Note`: All of these are great languages we respect. But none of them are what we want. So we created valk to do things our way.

When not to use Valk:

- When you need very low-level control. E.g. custom assembly code / register access.

- When your program needs to run on niche infrastructure. We currently only support: win/linux/mac for x86_64/arm64.

- Creating .dll/.so/.a/.lib files. (We will support this in the future)

## Language design

- Co routines are semi-stackful. We run the co-routines on the main stack and if it blocks, we copy it to a temporary buffer. This way we can keep memory usage low. And yes, it's fast.

- Each thread manages it's own memory. So we dont need to block other threads. You can share objects with other threads. Each time you do, the shared memory counter increases. At a certain point it will block other threads to free un-used shared objects. But we never block every X seconds like other languages do.

- The local GC has no randomness. Every time you run a program it will use the exact same amount of memory and run at the exact same speed.

- Co routines are single threaded. We dont do task-stealing.

- We are a self hosted language with a LLVM backend. We depend on libc for system calls. We use the OS default linker for linking (ld/ld64/link.exe).

## Contributions

We are mainly looking for people who want to add more functionality either via packages or pull requests to the standard library.

If you have an idea of what you want to add but dont know how to start, hop on our discord channel and ask for help.

Highly requested: Hashing/encryption methods, Popular tool/service integrations (e.g. mysql, postgres, S3 api, GUI libraries, ...)

---

<div align="center"><p>
    <img src="https://raw.githubusercontent.com/valk-lang/valk/main/misc/valko-circle.png">
</p>
</div>
