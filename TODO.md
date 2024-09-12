
# TODO

- improve exit_fn syntax `exitfn`
- make exit a built-in function instead of using valk:os:exit()
- `construct new() {}` instead of `static fn new() {}`
-- This forces the use of the use of `new()` to create an object of that class (multiple constructors allowed)
- when you create a new object and you dont pass in a property value and there's no default value
-- if nullable, use `null` as value, if it has a `construct` without arguments, use that
- enums
