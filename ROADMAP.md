
# Roadmap

`+` = Done | `~` = Works but needs to be improved | `-` = Todo

```
- Release 0.2.7
- Date/time classes

+ Release 0.2.6
+ Adjust package directory lookup
+ Improve error payload parsing
+ Fix Array prepend many
+ Implement `--valkir` flag

# Next steps

- Data race solution

# Other

- Complete libc integration
- Provide a `IR` build so people can build valk with `clang` instead of `valk`
- vman templates -> vman template http-server-router ./src
- Allow all types of 128 bit and lower as function arguments
- Full HTTP 1.1 protocol + Cookies
```

## Maybe

```
- on exit thread/process { ... }
- WASM support
- Allow @undefined for entire struct. E.g. let user = User { @undefined }
- @stack(StructName) -> stackalloc StructName { ... }
-- This is the same as `let x : <StructName> = { ... }`
-- but stackalloc can be used as a value, e.g. in function arguments
```

## Done

```
+ Release 0.2.5
+ Bugfixing

+ Release 0.2.4
+ load "define" from config (alternative for --def)
+ valk command output & usage improvements

+ Release 0.2.3
+ Json improvements
+ Http lowercase header keys
+ Extend access types `~+ -+ -~ -~+`
+ IR & type improvements
+ [start-index .. length] -> calls the $range function (start_index: uint, length: uint)

+ Release 0.2.2
+ Tagged unions
+ Class interfaces
+ Lib bug fixes

+ Release 0.2.1
+ `$default` type value hook
+ LSP improvements
+ Defer statements

+ Release 0.2.0
+ Rewrite entire compiler
+ valk code formatter


+ Release 0.1.14
+ Improve watch command
+ Validator functions
+ Template improvements
+ Package platform (vpkg.dev)
+ Http fixes
+ Rename `--no-default-libs` to `--no-system-libs`
+ Json changes `.get` -> `.get_or`
+ Allow using `main` namespace from another package

+ Release 0.1.13
+ Process class to start a process async

+ Release 0.1.12
+ Fix errors missing payload, e.g. println(E.message) -> crash, because no message was set in the throw code
+ SSL allow to disable ca-cert host verification
+ ByteReader + Rewrite ByteBuffer functions
+ Move 'type' namespace to 'core'
+ Only allow references on local variable
+ each ... skip ... as ... {}

+ Release 0.1.11
+ Rework namespaces
+ Nullable int
+ fnptr -> fn without allocation
+ use error pass handler by default
+ 1 object per file instead of namespace

+ Release 0.1.10
+ options: --no-default-libs --link-arg {arg} --sysroot {path}

+ Release 0.1.9
+ Rework errors

+ Release 0.1.8
+ Multi assign
+ Directory as package src
+ Crypto: base64/sha1/sha256

+ Release 0.1.7
+ --release option
+ json optimizations
+ slice type + array optimizations
+ rework value scope parsing

+ Release 0.1.1 - 0.1.6
+ Optimizations & rewrites

+ Release 0.1.0

+ A `--watch` build argument
+ A `--ir` build argument (output is a single IR file)
+ Improve link command
+ Release 0.0.17

+ Markdown parser
+ Embed file into code `#embed({path})`
+ Rename `#STR` to `#string`
+ A `extern` keyword to define things in .valk files instead .valk.h
+ Remove all header logic - no more `.valk.h` files
+ Release 0.0.16

+ LSP improvements
+ rename `fnRef` -> `fnptr`
+ Release 0.0.15

+ Fix function type type-checking
+ Improve docs
+ Make sure the LSP works on windows
+ Check `TODO` in the code base
+ Release 0.0.14

+ Shared array/map locks & .$is_shared builtin
+ Rework stack allocation arrays & structs + init values
+ Update docs
+ Release 0.0.13

+ Syntax clean up
+ Release 0.0.12

+ Re-enable multi threaded compiling
+ Fix closure data binding order
+ Fix cast ptr -> u32/u16/u8
+ Rework async IO
+ Rework stack & coroutines
+ Socket API change
+ Remove `utils` namespace / move ByteBuffer to `type` namespace
+ Rework AST parse flow
+ Async mutexes
+ Release 0.0.11

+ Fix shared gc bug
+ Release 0.0.10

+ template engine improvements
+ Rework arrays from `@array[...]{...}` to `{1, 2, 3}`
+ Basic crypto functions
+ Improve enums
+ Release 0.0.9

+ valk lsp
+ vscode extension
+ Release 0.0.8

+ fn encode[T](value: T) -> fn encode(value: $T)
+ valk doc
+ use "x" as X { a, b as B, c }
+ Allocate stack/heap arrays : @array[u8 x 3]{ 'a', 'b', 'c' }
+ Copy on assign if not pointer or number
~ template engine
+ Release 0.0.7

+ Update HTTP client options
+ Release 0.0.6

+ Allow identifiers for numbers in types, e.g. ptr[u8 x fs:PATH_MAX_LEN] or global list : [uint x MAX_ITEMS]
+ Add more standard library functions
+ Update docs
+ Release 0.0.5

+ Rework GC to remove reconnect list
+ Http option follow redirects (default: true)
+ Use fs:resolve on all paths in the compiler
+ Warn unused variables / namespaces. And --no-warn/-nw option
+ Type modes (mode Path for String) (extends type but no new properties allowed)
+ Dont use hashes to compare IR. Just compare file content (= faster & more correct)
+ Release 0.0.4

+ Use $lazy properties in compiler
+ Path class for creating correct win/macos/linux paths
+ Release 0.0.3

+ Finish all GC related todos
+ Add more basic features
+ Release 0.0.2

+ Release 0.0.1
```
