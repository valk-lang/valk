
# Roadmap

## Things to do

```
+ Release 0.0.1

+ Finish all GC related todos
+ Add more basic features
+ Release 0.0.2

+ Use $lazy properties in compiler
+ Path class for creating correct win/macos/linux paths
+ Release 0.0.3

+ Rework GC to remove reconnect list
+ Http option follow redirects (default: true)
+ Use fs:resolve on all paths in the compiler
+ Warn unused variables / namespaces. And --no-warn/-nw option
+ Type modes (mode Path for String) (extends type but no new properties allowed)
+ Dont use hashes to compare IR. Just compare file content (= faster & more correct)
+ Release 0.0.4

+ Allow identifiers for numbers in types, e.g. ptr[u8 x fs:PATH_MAX_LEN] or global list : [uint x MAX_ITEMS]
+ Add more standard library functions
+ Update docs
+ Release 0.0.5

+ Update HTTP client options
+ Release 0.0.6

+ fn encode[T](value: T) -> fn encode(value: $T)
+ valk doc
+ use "x" as X { a, b as B, c }
+ Allocate stack/heap arrays : @array[u8 x 3]{ 'a', 'b', 'c' }
+ Copy on assign if not pointer or number
~ template engine
+ Release 0.0.7

+ valk lsp
+ vscode extension
+ Release 0.0.8

+ template engine improvements
+ Rework arrays from `@array[...]{...}` to `{1, 2, 3}`
+ Basic crypto functions
+ Improve enums
+ Release 0.0.9

+ Fix shared gc bug
+ Release 0.0.10

+ Re-enable multi threaded compiling
+ Fix closure data binding order
+ Fix cast ptr -> u32/u16/u8
+ Rework async IO
- Release 0.0.11

- Share project with others?
- Use correct windows api and waitForMultipleObjects
- Make wait-for-thread non-blocking
- Full HTTP 1.1 protocol + Cookies
- async file read/write
- Better errors
- valk fmt
- Release 0.0.x

- Interfaces
- Union types
- Release 0.0.x
```

## For later

```
- $only_if_used
- WASM support
- Only parse functions from imut classes when they are used so we no longer need `mut fn`
```

## Maybe

```
- [value .. value] -> calls the $range function (from: uint, until: uint, inclusive: bool)
- error pass operator `!>`
- remove shadow stack, use real stack
- `construct new() {}` instead of `static fn new() {}`
-- This forces the use of the use of `new()` to create an object of that class (multiple constructors allowed)
-- if property is nullable, use `null` as value, if it has a `construct` without arguments, use that
- Dont use shadow stack, use real stack
- Use Bump allocator instead of Pool allocator
- Make type.class non nullable, all types must have class, pointer void, pointer fnRef, class Closure, class Promise/Coro
```
