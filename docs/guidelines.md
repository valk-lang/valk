
# Project Guidelines

## Priority of the code

1. Correctness (Most important)
2. Performance
3. Low memory usage
4. Simplicity
5. Everything else (Least important)

## Method

- Be sure your code works, doesnt crash or leak memory
- When changing code that could affect the performance, verify and measure the performance gain/loss.

## API Design

### Argument order

1. Input / source / from
2. If there is an input argument: arguments essential to know what the output should be like (e.g. algorithm, format, base, pattern)
3. Target / out / to
4. Remaining required arguments (e.g. output limit, byte count)
5. Optional arguments — ordered by most commonly used

Note: on methods, `this` counts as the input argument.
Note: `fs.write` has filepath first, content: second. even though filepath could be seen as an out, the function has to first open the file before starting to write content. So filepath is an input and it comes first because it's used in the first phase of the function (opening the file).

### Naming & defaults

- Prefer `?T (null)` over empty-string (`""`) for optional values.
- A `0` integer value for `unlimited` is prefered unless `0` should be a valid value for the argument.
- A `0` integer value for `donothing` is also prefered over a nullable integer.
- Use clear, descriptive parameter names e.g. `route_prefix` over `prefix` when it's not clear what the prefix is for
- When writing a function that outputs a string, try having an `_in` and an `_into` variant of that function:
-- `_into` has an `out: io.Writer` argument and returns the result length.
-- `_in` has an `out: local &[u8]` argument and returns the result length. This variant should only exist if the result/output length is somewhat known upfront because this variant is used to e.g. write the output directly to a slice allocated on the stack. Also dont create this variant if the output can be too big to be realistically allocated on the stack.
