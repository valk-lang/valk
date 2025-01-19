
# TODO

- convert AST to IR per function. Only generate complete IR & .o after all files have gone through this process. This allows us to re-parse any function on the fly (e.g. $parse_last) and allows namespace A to generate generics in namespace B.
- Rename `sizeof` to `size_of`. Use underscores everywhere.
- replace `exit fn` with `$exit` flag
- make exit a built-in function instead of using valk:os:exit()
- `construct new() {}` instead of `static fn new() {}`
-- This forces the use of the use of `new()` to create an object of that class (multiple constructors allowed)
- when you create a new object and you dont pass in a property value and there's no default value
-- if nullable, use `null` as value, if it has a `construct` without arguments, use that
- enums
- array sort & custom sort
