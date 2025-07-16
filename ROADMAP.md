
# Roadmap

## Things to do

```
+ Release 0.0.1
+ Switch main to 0.0.2
+ Finish all GC related todos
+ Add more basic features
+ Release 0.0.2
- Create branch 0.0.3
- Implement all standard library functions
- Update docs
- Merge 0.0.3 into main + Release
- Create branch 0.0.4
- Use $lazy properties in compiler
- Use correct windows api and waitForMultipleObjects
- Make wait-for-thread non-blocking
- Allow identifiers for numbers in types, e.g. ptr[fs:PATH_MAX_LEN x u8] or global list : [MAX_ITEMS x uint]
- Interfaces
- Union types
- WASM support
- Merge 0.0.4 into main + Release
```

## For later

```
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
