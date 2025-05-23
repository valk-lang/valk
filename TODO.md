
# TODO

```
- match operator
- Short way to create arrays and objects
-- let x = []#i32, let x : Array[i32] = [], let x = [5#i32]
- $to $autoconvert : let x = 5 to String
- Make type.class non nullable, all types must have class, pointer void, pointer fnRef, class Closure, class Promise/Coro
- [value .. value] -> calls range()
- Use flags instead of specific function names: $converter, $range
- Only parse functions from imut classes when they are used so we no longer need `mut fn`
- `--ignore-access-types` build option to ignore pub/read access types
- Clean up `scopes` code/logic in the compiler code
- Use Pool allocator for array and string objects/data, malloc/free is way too slow
- Coroutine/thread exit
- Coroutine globals
- Interfaces
- Extend classes/structs
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
