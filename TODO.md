
# TODO

```
- Fix `<{}` vscope and function multi return bugs
- enums
- array sort & custom sort
- Coro sleep function
- rework access-types + check access-types : pub/read, default private: pub pub_ns pub_pkg read read_ns read_pkg
- quick access using square brackets e.g `array[0]` or `"test"[1]` and calls `fn get_offset()` hook, on assign `mut fn set_offset()`
- make type.class non nullable, all types must have class, pointer void, pointer fnRef, class Closure, class Promise/Coro
- [value .. value] -> calls range()
- only parse functions from imut classes when they are used so we no longer need `mut fn`
- `--ignore-access-types` build option to ignore pub/read access types
- clean up `scopes` code/logic in the compiler code
```

# Maybe

```
- remove shadow stack, use real stack
- `construct new() {}` instead of `static fn new() {}`
-- This forces the use of the use of `new()` to create an object of that class (multiple constructors allowed)
-- if property is nullable, use `null` as value, if it has a `construct` without arguments, use that
- Dont use shadow stack, use real stack
- Use Bump allocator instead of Pool allocator
```
