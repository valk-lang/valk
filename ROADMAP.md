
# Roadmap

`+` = Done | `~` = Works but needs to be improved | `-` = Todo

```
# Upcoming version

+ Fix function type type-checking
- Improve docs
- Make sure the LSP works on windows
- Check `TODO` in the code base
- Add `link_dir` token for header files
- Release 0.0.14
- Share project with others

# Next steps

~ Work out bad features: cothrow, imut
- Full HTTP 1.1 protocol + Cookies
- valk fmt
- Interfaces
- Union types
```

## Maybe

```
- Convert grouped values to inline struct types
- Data race solution
- Change function syntax to `exampleFunc` instead of `example_func`
- WASM support
- Dont use shadow stack, use real stack
- Only parse functions from imut classes when they are used so we no longer need `mut fn`
- [value .. value] -> calls the $range function (from: uint, until: uint, inclusive: bool)
- `construct new() {}` instead of `static fn new() {}`
-- This forces the use of the use of `new()` to create an object of that class (multiple constructors allowed)
-- if property is nullable, use `null` as value, if it has a `construct` without arguments, use that
```

## Done

```
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
