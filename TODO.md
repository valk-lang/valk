
# TODO

```
- `clone` token + `after_clone` hook
- immutable type - clone value to convert to/from immutable `imut`
- force immutable on shared globals
- Rename `sizeof` to `byte_size` & `bit_size`
- Use underscores for all tokens .e.g `byte_size` instead of `bytesize`
- replace `exit fn` with `$exit` flag
- make `exit`, `panic` built-in functions instead of using e.g. valk:os:exit()
- enums
- array sort & custom sort
- Fix `<{}` vscope and function multi return bugs
- Coro sleep function
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
