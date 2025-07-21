
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
- Type modes (mode Path for String) (extends type but no new properties allowed)
+ Release 0.0.4
- Use Path mode in compiler
- Implement all standard library functions
- Use correct windows api and waitForMultipleObjects
- Make wait-for-thread non-blocking
- Allow identifiers for numbers in types, e.g. ptr[fs:PATH_MAX_LEN x u8] or global list : [MAX_ITEMS x uint]
- Update docs
- Release 0.0.5

- Interfaces
- Union types
- Release 0.0.6
```

## For later

```
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
