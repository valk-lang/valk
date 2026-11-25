
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

### Naming & defaults

- Prefer `?T (null)` over empty-string (`""`) for optional values.
- Use clear, descriptive parameter names e.g. `route_prefix` over `prefix` when it's not clear what the prefix is for
