
# TODO

```
- Coroutine globals
- Interfaces
- Union types
- Extend classes/structs
- Only parse functions from imut classes when they are used so we no longer need `mut fn`
- $lazy properties
- change pointer array types from: [u8 x 10] -> to: ptr, ptr[u8], ptr[u8 x 10]
```

# Later

```
/
```

# Maybe

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
