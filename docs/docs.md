
# Documentation

## Table of contents

<table>
<tr><td width=200px><br>

* [Standard library API](#standard-library-api)
* [Getting started](#getting-started)
* [Basic example](#basic-example)
* [Types](#types)
* [Variables](#variables)
* [Strings](#strings)
* [Arrays](#arrays)
* [Maps](#maps)
* [Typehints](#typehints)
* [Tagged unions](#tagged-unions)


<br></td><td width=200px><br>

* [Functions](#functions)
   * [Errors](#errors)
   * [Error handling](#error-handling)
   * [Throw functions](#throw-functions)
   * [Deferred calls](#deferred-calls)
   * [Exit functions](#exit-functions)
   * [Closures](#closures)
* [Classes](#classes)
* [Interfaces](#interfaces)
* [Generics](#generics)
* [Modes](#modes)
* [Traits](#traits)
* [Globals](#globals)
* [Aliases](#aliases)
* [Tokens](#tokens)
    * [Let](#variables)
    * [If/Else](#if-else)
    * [While](#while)
    * [Each](#each)
    * [Throw](#errors)

<br></td><td width=200px><br>

* [Null checking](#null-checking)
* [Files](#files)
    * [Paths](#paths)
* [JSON](#json)
* [DateTime](#datetime)
* [Coroutines](#coroutines)
* [Access Types](#access-types)
* [Value Scopes](#value-scopes)
* [Compile macros](#compile-macros)
* [Atomics](#atomics)
* [Testing](#testing)
* [HTTP Client](#http-client)
* [HTTP Server](#http-server)
* [Sockets](#sockets)
* [Templates](#templates)
* [Crypto](#crypto)

<br></td><td width=200px><br>

* [Embed](#embed)
* [Namespaces](#namespaces)

* [Unsafe](#unsafe)
    * [Structs](#structs)
    * [External libraries](#external-libraries)
    * [Linking](#linking)
    * [Building native libraries](#building-native-libraries)

* [Valk manager](#valk-manager)
* [Data races](#data-races)

<br></td></tr>
</table>

## Standard library API

See: [API docs](api.md)

## Getting started

Install on Linux, macOS, or WSL:

```sh
curl -sSL https://valk-lang.dev/install.sh | bash
```

Windows (via PowerShell):

```sh
irm https://valk-lang.dev/install.ps1 | iex
```

Manual download: [Download page](https://valk-lang.dev/download)


## Basic example

```rust
// main.valk
fn main() {
    println("Hello world!" + " 🎉")
}
```

```sh
valk build main.valk -o ./main
./main
```

`main` can take the command line arguments; the first one is the program path.

```rust
fn main(args: Array[String]) {
    each args as arg : println(arg)
}
```

## Types

Integer types: `int`, `uint`, `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`

Float types: `float`, `f32`, `f64`. Float literals may use an exponent: `2.5e-3`, `1e10`

Built-in classes: `String`, `Array`, `Map`, `HashMap`

Nullable types: `?String` allows the value to be `null`

`nonnull(T)` removes one nullable layer from `T`. Same as `T.$nonnull`

Function pointer: `fn({arg-types})({return-types} !Error)` e.g. `fn(i32)(bool !ParseError)`

Raw function pointer: `fnptr({arg-types})({return-types} !Error)` e.g. `fnptr(i32)(bool !ParseError)`

Coroutine type: `co({return-types} !Error)` e.g. `co(i32 !ParseError)`

Other: `ptr` <- raw pointer (unsafe)

Integers do not convert implicitly to raw pointers; use `value.@cast(ptr)` when
intentionally forging an address. A raw `ptr` converts implicitly to `uint`.

---

`int` becomes `i32` or `i64` based on the compile target

`uint` becomes `u32` or `u64` based on the compile target

Every integer type exposes its range as `T.$max` and `T.$min`, e.g. `u8.$max` is `255`

`float` becomes `f32` or `f64` based on the compile target

## Variables

```rust
// let {name} [: {type}] = {value}
let count = 5                  // Inferred as int
let unsigned: uint = 5         // Explicit type
let converted = count.to(uint)
let text: String = count       // Converted to String automatically
let parsed = "100".to(u8) !? 0 // Parsing text throws SyntaxError: not a number, or outside the u8 range
```

Unary `-` accepts any integer or floating-point expression, including variables,
calls, and parenthesized expressions. Applying it to another type is a compile
error.

## Strings

```rust
let name = "Peter"
let msg1 = "Hello " + name + "!" // Concat strings
let msg2 = "Hello %name!" // Short way
let msg3 = "Name length x 2: %{ name.length * 2 }!" // Any expression that can be converted to String
let msg4 = "Hello \%name!" // Escape the %
let msg5 = r"Hello %name!" // Raw string
// Basics
s.length // Length in bytes
s.starts_with(x) bool
s.ends_with(x) bool
s.is_empty() bool
s.contains(x) bool
s.lower() String // Convert Unicode text to lowercase
s.upper() String // Convert Unicode text to uppercase
s.range(start_index, length) String // Sub string using byte offsets
s[i] // Byte at index i; an index past the end reads 0
let middle = s[1 .. 3] // Same as s.range(1, 3): three bytes starting at byte offset 1
s.utf8.length // Length in Unicode characters
s.utf8.range(start_index, length) String // Sub string using character offsets
each s.utf8.chars() as ch { } // Iterate Unicode characters (each `ch` is a String)
each s as byte { } // Iterate bytes (u8)
```

Full `String` API: [core](api.md#core)

## Regular expressions

API for [valk.regex](api.md#regex)

`Regex.new(pattern, flags)` compiles a pattern once; the flags are `i` for
case-insensitive, `m` for `^` and `$` at line boundaries, and `s` for `.`
matching newlines. Matching never backtracks: every pattern runs in time
proportional to the text length times the pattern size, so untrusted
patterns cannot hang a program. Offsets are byte offsets into the text.

```rust
use valk.regex

let re = regex.Regex.new("(?P<user>\\w+)@(?P<host>[\\w.]+)") ! panic("bad pattern")
let m = re.find("mail me@example.com today") ?! return
println(m.str())                       // me@example.com
println(m.named("host") ?? "")         // example.com
println(m.get(1) ?? "")                // me
println(m.start)                       // 5

each re.find_all("a@b.c x@y.z") as found : println(found.str())
re.is_match("nothing here")           // false
re.replace("me@home you@work", "${host}:${user}")   // home:me work:you
re.replace_with(text, fn(m: regex.Match) String { return m.str().upper() })
regex.Regex.new("\\s*,\\s*").!.split("a , b,c")     // ["a", "b", "c"]
regex.escape("1+1=2")                  // 1\+1=2
```

Supported syntax: literals and escapes (`\n \t \xHH \x{HHHH}`), `.`,
classes `[a-z]`, `[^...]`, `\d \w \s` and their negations (ASCII), POSIX
classes `[[:alpha:]]`, anchors `^ $ \A \z`, word boundaries `\b \B`, groups
`(...)`, `(?:...)`, `(?P<name>...)`, `(?<name>...)`, inline flags `(?i)` and
`(?i:...)`, quantifiers `* + ? {n} {n,} {n,m}` with a `?` suffix for lazy
matching, and alternation `|`. Alternation is leftmost-first like Perl and
RE2: `a|ab` on `ab` matches `a`. Backreferences, lookaround and `\p{...}`
classes are not supported and fail with `unsupported`; malformed patterns
fail with `syntax` and carry a `message` and byte `position`. Case folding
covers ASCII and simple one-to-one Unicode mappings. Patterns match code
points, and a byte that is not valid UTF-8 matches as the code point of its
value.

## Arrays

Prefer `append` over `prepend` when possible; appending is significantly faster.

```rust
let arr = Array[int]{ 1, 2, 3 } // Create array
let arr : Array[int] = .{ 1, 2, 3 } // Using typehint
let zeros = Array[int]{ 0 x 10 }  // Ten copies of one value (Array.fill)
// Basics
arr.append(4)
arr.prepend(5)
let v = arr.get(0) ! panic("Empty array")
let first_three = arr[0 .. 3] // Same as arr.range(0, 3)
arr.clear()
//
each arr as value {}
each arr as value, index {}
```

Full `Array` API: [core](api.md#core)

Callbacks cover the common searches and transforms: `any`, `all` and `find`
take a `fn(T)(bool)`, `map[R]` builds a new array from a `fn(T)(R)`, and
`reduce[R](init, fn(R, T)(R))` folds the elements into one value. `filter`
copies matching items into a new array. `remove_where` removes matching items
from the original. `extract` takes matching items out of the original and
returns them. Arrays of numbers also offer `sum()`, `min()` and `max()`, and
`shuffle()` randomizes the order.

```rust
let nums = Array[int]{ 3, 1, 2 }
let has_big = nums.any(fn(v: int) bool { return v > 2 })
let strs = nums.map[String](fn(v: int) String { return v.to(String) })
let total = nums.reduce[int](0, fn(t: int, v: int) int { return t + v }) // 6, same as nums.sum()
```

Use `arr.sort()` for elements that support ordering. Other element types require
a comparator whose parameters have the element type; for an `Array[Array[int]]`:
`rows.sort(fn(a: Array[int], b: Array[int]) bool { return a[0] > b[0] })`.
The comparator returns true when `a` should come after `b`.

Fresh slice storage is a language form, not a class: `[int]{ 1, 2, 3 }`
allocates from a list and returns the `&mut [int]` that owns the elements,
`[u8]{ 0 x n }` repeats a value `n` times. `[T]{ null x n }` skips the fill and is only safe when every
zero `T` is a valid value; for reference elements it requires `@unsafe`.
Container methods resize containers and create views. Writing the raw storage
fields of an `array` or `slice`, including their length, requires `@unsafe`,
even in the source that declares the type.

`arr[i]` on an `Array` of structs hands out a copy of the element, because the
array's storage can move when it grows. Assigning into that copy, or calling a
method that changes it, is a compile error; borrow the element with
`&mut arr[i]`, write through a writable view (`arr.view()` returns an
`&mut [T]`), or store the changed struct back with `arr.set(i, value)`.

A borrow only reads unless it says `mut`: `&[T]` and `&T` are read-only
views, `&mut [T]` and `&mut T` may be written through. A slice type declared
with `$immutable`, like `String`, is read-only everywhere outside its own class. Any slice, array or
string converts to `&[T]`, so `fn write(data: &[u8])` accepts strings, byte
buffers and slices without copying, while `fn read(buf: &mut [u8])` needs
writable storage. Assigning through a read-only borrow, taking `&mut` of one
of its elements, or calling a method that changes it is a compile error.
A named slice such as `String` or your own `slice Bytes of u8 {}` converts to
the bare forms, never the other way around, and two different names never
convert to each other: a name is a promise only its own class can keep.

A fixed array on the stack, such as `let key: [u8 x 4] = { 1, 2, 3, 4 }`,
also converts to `&[T]` or `&T` when passed to a function, as long as that
function provably keeps nothing: it may read and pass the borrow on, but a
callee that stores it in an object, returns it, or hands it to a coroutine
gets "Cannot convert a stack borrow" at the call, because the storage dies
with the caller's frame. The same applies to a `stack T` borrow. Storage
that must be kept belongs in a class property, a global, or a heap slice
such as `[u8]{ 0 x 4 }`.

A fixed array `[T x N]` stores `N` elements inline. Its length cannot change, and indexes are checked at compile time when they are known.

```rust
let sizes: [int x 3] = { 1, 2, 3 }
sizes[1] = 20
println(sizes.length) // 3
print_sizes([int x 3]{ 4, 5, 6 })
```

`[T x N]{ ... }` writes a fixed array where a value is needed; `{ ... }`
suffices when the type is already known, and `v...` repeats the last value
to the end.

Every range in Valk is a start offset and a length, never a start and an end,
so there is no inclusive or exclusive bound to remember. `value[start .. length]`
and `value.range(start, length)` return a copy. `&value[start .. length]` and
`value.view(start, length)` return a view that shares the elements with `value`:

```rust
let values = Array[int]{ 1, 2, 3, 4 }
let copy = values[1 .. 2]  // Array[int], independent of values
let view = &values[1 .. 2] // &mut [int] over the same elements
view[0] = 20               // values is now { 1, 20, 3, 4 }
```

Both forms call an instance method: `$range` for the copy and `$view` for the
view. The hook must accept `(start_index: uint, length: uint)` and return one
value. This lets custom collection types support the same syntax.

## Maps

A `Map` is a key/value store with `String` keys and a configurable value type. Use `HashMap` when keys are not strings.

```rust
let m = Map[uint]{ "a" => 1, "b" => 2 } // Create map
let m : Map[uint] = .{ "a" => 1, "b" => 2 } // Using typehint
// Basics
m.set(key, value)
m.remove(key) // Swap-remove: the last entry takes the removed slot, so iteration order changes
m.has(key)
m.clear()
//
each m as value {}
each m as value, key {}
each m as value, key, index {}
```

Full `Map` API: [core](api.md#core)

If you need non-string keys, use `HashMap`. `HashMap` and `Map` are compatible types.

```rust
let h = HashMap[uint, String]{ 5 => "x", 10 => "y" }
// Map and HashMap are compatible types as long as the key/value types match
let a : Map[uint] = .{ "v1" => 10 }
let b : HashMap[String, uint] = a
let c : Map[uint] = b
```

Full `HashMap` API: [core](api.md#core)

## Sets, deques and heaps

`HashSet` holds unique values, hashed like `HashMap` keys. `Deque` is a
double-ended queue with amortized constant-time pushes and pops at both ends
and indexed access from the front. `Heap` is a binary heap that pops the
smallest item first, or the item a comparator puts first.

```rust
let seen = HashSet[String]{ "a", "b" }
seen.add("c")                 // chainable; insert() tells whether the value was new
seen.has("a")                 // true
seen.remove("b")              // true when it was present
let both = seen.intersection(HashSet[String]{ "a", "z" })
let all = seen + HashSet[String]{ "z" }   // union
each seen as value {}

let queue = Deque[uint]{ 2, 3 }
queue.push_front(1)
queue.push_back(4)
let first = queue.pop_front() ! panic("empty")   // 1
let last = queue.pop_back() ! panic("empty")     // 4
queue[0]                      // indexed from the front
queue[0] = 9 !!               // assignment throws `missing` out of range

let heap = Heap[int]{ 5, 1, 4 }
let smallest = heap.pop() ! panic("empty")       // 1
let by_length = Heap[String].new(fn(a: String, b: String) bool { return a.bytes < b.bytes })
```

Full API: [core](api.md#core)

An indexed assignment goes through the type's `$offset_assign` hook, and
that hook may throw. The handler then follows the assignment: `deque[i] = v
!!`, `deque[i] = v ! { ... }` or `deque[i] = v !? _`, and without one the
error passes to the caller like any other. When the right-hand side itself
throws, the handler belongs to that value; parenthesize it to give the
assignment its own: `deque[i] = (compute() !? 0) !!`. `Type{ v x n }` builds
any class with a `static fn fill(count, value)`, as `Array` has.

## Typehints

Variables, properties, globals, and function arguments can have explicit type hints. When the expected type is known, `.` can construct a value of that type without repeating its name.

```rust
// Variables
let x : Array[int] = .{ 1, 2, 3 }
// Function arguments
fn test(list: Array[int]) {}
test(.{ 1, 2, 3})
// Properties
class A {
    list: Array[int]
}
let ob = A { list: .{ 1, 2, 3 } }
// Operators also typehint for the value on the right side
let is_equal = (ob.list == .{ 3, 2, 1 })
```

A typehint on a number only types plain literals: `let x: u8 = 200 + 55` is a `u8`
constant, while `let y: i16 = a + b` computes `a + b` in the operands' type and
converts the result.

## Tagged unions

A tagged union lets a value be one of several types. Give the union a name when
you want to reuse it:

```rust
union Value : String | int | bool | null {}

fn describe(value: Value) String {
    return match value : String {
        null => "missing"
        String as text => text
        int as number => "number: %number"
        bool as enabled => enabled ? "enabled" : "disabled"
    }
}

let value: Value = 42
println(describe(value))
```

A nullable subject may have a `null` case; an enum match on a nullable enum is exhaustive when `null` and every item are handled. Use `as` to access the value in a `match` case. When every type is handled, a
`default` case is not needed. The type
after `match value :` is the type every case must produce. Leave it out when the
`match` is a statement rather than a value. A case of a value `match` may also
leave instead of producing a value, with `return`, `throw`, `break`, `continue`
or `panic`. A `match` on a `bool` is exhaustive when `true` and `false` are handled.

A `null` alternative is a value of its own, like JSON's `null`: a `Value` holding
it is set, and `?Value` still says whether there is a value at all. An alternative
itself cannot be nullable; write `?Value` for a union that may be missing. A `null`
case matches the alternative and, on a nullable subject, a missing value too.

For a union used only once, write it directly as a type, such as
`String | int`. Named unions can also contain functions and getters.

## Functions

```rust
// Arg2 has a default value of 5
// Default values are defined between brackets `()` after the argument type
fn add(arg1: int, arg2: int (5)) int {
    return arg1 + arg2
}

fn main() {
    add(1)    // result: 6
    add(2, 2) // result: 4
    add()     // Compile error
}
```

Calls evaluate the callable or method receiver first, then arguments from left to right. `co` uses the same order before starting the coroutine.

Command line arguments are passed to `main` when it declares an `Array[String]` argument (the first item is the program path):

```rust
fn main(args: Array[String]) {
    each args as arg : println(arg)
}
```

Append `$inline` to request inlining, or `$noinline` to prevent it:

```rust
fn add_one(value: int) int $inline { return value + 1 }
fn add_two(value: int) int $noinline { return value + 2 }
```

These flags cannot be combined on the same function.

### Type default values

A class, struct, or other named type can provide the value returned by
`.$default_value` with a static function marked `$default`:

```rust
struct Point {
    x: int
    y: int

    static fn origin(x: int (0), y: int (0)) SELF $default {
        return SELF { x: x, y: y }
    }
}

let point: Point = Point.$default_value
```

The function must be static and return its own type. Its arguments, if any,
must have default values. Omitted non-null properties use the same default;
nullable types default to `null`.

### Deferred calls

Use `defer` to schedule a function call for the end of the current function.
Deferred calls run after the return value or thrown error has been evaluated,
and before the function gives control back to its caller.

```rust
fn use_resource(resource: Resource) {
    defer resource.close()

    resource.write("done")
}
```

Deferred calls run in reverse order when the function returns or passes an
error to its caller. Values are captured when `defer` is reached. If the call
can return an error, handle it on the `defer` line.

### Errors

Functions can return errors using `throw`. But first you need to define an error type or you can use one of the built-in ones.

An error type must provide at least one error code or extend at least one existing error type. Payload fields can carry additional error data. Each field may declare an explicit default with the same `(value)` syntax used for class properties and function arguments.

```rust
error {Error type name} ({codes}) [extends ({error types})] [payload { {field-name}: {type} [(default)] }]
// Example
error MyError (invalid_input, missing_key) extends (LookupError) payload {
    message: String
    key: Key
    detail: String ("")
}
```

Usage:

```rust
fn find_value(key: Key) Value !MyError {
    //...
    // Required payload fields must be set; fields with an explicit default may be omitted.
    throw .missing_key { message: "Key not found", key: key }
    //...
}
```

When rethrowing inside an error handler, omitted fields that already exist on a
compatible caught `E` are passed through.

Pure pass (`!>` / the default pass) keeps the original error code and payload. If
the caller error type adds **required** payload fields (no explicit default) that
the callee does not have, the pass is a compile error — set them with a rethrow:

```rust
inner() ! throw E { detail: "missing on the inner error" }
```

Fields with an explicit payload default may still be omitted on both throw and pass.

Built-in error types:

```rust
AnError (error) // Generic error
SystemError (failed, unsupported) // For when the operating system cannot answer a query, such as the number of CPU cores
IterError (end) // You can end an 'each' loop with any error or you can use this one
InitError (init) // Common error
LookupError (missing, exists, range, empty) // For when a function needs to find or store something
SyntaxError (syntax) // Common error
```

### Error handling

When calling this function the error must always be handled. There are many ways to do this:

```rust
// !? Provide an alternative value when an error occurs
let v = my_func() !? "hello"
// ! Run code if the function returns an error
my_func() ! { print("error") }
// If the call's value is needed, the handler must return an alternative value
// or exit through return, break, continue, throw, panic, or an exit function.
let v = my_func() ! { print("error"); return }
// A value scope may also exit instead of returning a value
let v = my_func() !? <{ log("failed"); throw .failed }
// ! You can also use a single line
let v = my_func() ! return
// !> pass the error to the parent caller
let v = my_func() !>
// _ Ignore the error, but the return type/value is always `void`
my_func() _
// !! panic on error
let v = my_func() !!
```

You can access all error information with the `E` identifier. `E.code` contains the error code that was thrown. `error_is(E.code, name)` compares against one or more bare code names and is the same as `E.code == E.name`:

```rust
"x".to_int() ! {
    if error_is(E.code, syntax) : println("not a number")
}
```

```rust
fn main() {
    my_func() ! {
        // Checking the error code using `if`
        if E.code == E.fail : println("Error code `fail` was thrown")
        // Using 'match'
        match E.code {
            E.fail => println("Error code `fail` was thrown")
            E.nope => println("Error code `nope` was thrown")
            default => println("Another error was thrown") // Only required if not all codes were checked (compiler will tell)
        }
        // Payload data
        println(E.message)
    }
}
```

### Throw functions

Throw functions centralize repeated error construction. They are ordinary error-returning functions marked with `$throw`, which lets callers invoke them where a `throw` statement is required.

Example

```rust
error ParseError (invalid) payload {
    message: String
    line: uint
    col: uint
}

fn parse_error(parser: MyParser, message: String) !ParseError $throw {
    throw .invalid {
        message: message
        line: parser.location.line
        col: parser.location.col
    }
}

fn parse() !ParseError {
    // ...
    if something: parse_error(p, "This should not happen")
    // ...
}
```

### Exit functions

Calling a function that's flagged with `$exit` tells the compiler that the function will exit the program. E.g. the `panic` function. This mechanic is used for certain null-checking or error-handling features.

`panic(msg)` prints the message followed by the file and line it was called from, relative to the root of the package, then exits the process with status 1. Runtime checks report the same way: an index out of bounds, a division by zero, or an error left unhandled by `!!` names the line in your code where it happened.

```
Empty array at src/main.valk:12
Unhandled error 'LookupError.missing' at src/main.valk:20
Index out of bounds at src/core/ByteBuffer.valk:98 in package valk
```

```rust
fn myexit() $exit {
    println("I QUIT")
    exit(0)
}
fn main() {
    let str : ?String = null
    // ... some code ...
    if !isset(str) {
        println("This should not happen")
        myexit()
    }
    // Now the compiler knows that `str` cannot be `null` at this point
}
```

### Closures

Closures are anonymous functions that can have variables bound to them from outside their scope.

You can create anonymous functions using the `fn` keyword. A function literal that captures no outside variables can also be used as a raw function pointer (`fnptr`).

A raw function pointer can convert to a closure with a compatible signature. Use `fn` for callbacks that accept both raw function pointers and closures.

`object.method` binds the object as its receiver and requires a `fn` callback. It cannot convert to `fnptr`. `Type.method` leaves the receiver as the first argument and can be used as either kind of callback. A shared callback can bind a shared receiver.

Callback signatures do not implicitly convert argument or return values. Use a wrapper when a callback needs a value conversion or an added error declaration:

```rust
fn count() int { return 7 }

fn main() {
    let optional: fn()(?int) = fn() ?int { return count() }
    assert(optional() == 7)
}
```

The same applies to coroutine results: convert the value inside the coroutine, or after awaiting it.

```rust
fn main() {
    let prefix = "Hello"
    let greet = fn(name: String) {
        println(prefix + ", " + name)
    }
    greet("Sam")
}
```

A closure captures the current value of each outer variable when it is created; changing the variable afterwards does not change what the closure sees. Assigning to a captured variable inside the closure is an error. To share state, mutate an object the closure captures instead:

```rust
class Counter { count: int (0) }

fn main() {
    let counter = Counter{}
    let bump = fn() { counter.count++ }
    bump()
    bump()
    println(counter.count) // output: 2
}
```

## Classes

```rust
class User {
    first_name: String
    last_name: String ("Doe")

    fn print_name() {
        println(this.first_name + " " + this.last_name)
    }

    static fn my_static_function() {
        println("Hello from my static function")
    }
}

fn main() {
    let u = User {
        first_name: "John"
    }
    u.last_name += " The Great"
    u.print_name() // output: John Doe The Great
    User.my_static_function() // output: Hello from my static function
}
```

## Interfaces

Interfaces define methods that different classes can provide. Interface methods
end in `;`, and a class lists its interfaces with `is`.

```rust
interface Named {
    get name: String;
}

interface Printable {
    fn text(prefix: String) String;
}

class User is Named, Printable {
    first_name: String

    get name: String {
        return this.first_name
    }

    fn text(prefix: String) String {
        return prefix + this.first_name
    }
}

fn print(value: Printable) {
    println(value.text("User: "))
}
```

Only classes can implement interfaces. The compiler verifies that every method
has the same arguments, return type, getter or function form, and error type as
the interface declaration. A method that cannot fail may implement an interface
method that can; callers of the class then never handle an error, while callers
of the interface do.

Use `is_a` to check the concrete class held by an interface value:

```rust
if printable is_a User {
    print("user")
}
```

## Generics

With generics you can generate customized versions of a class or function.

```rust
// Generic class
class Data[T] {
    my_data: T
    fn getData() T {
        return this.my_data
    }
}
fn main() {
    let v1 = Data[uint]{ my_data: 10 }
    let v2 = Data[String]{ my_data: "hello" }
}
```

```rust
// Generic function
fn add[X, Y](v1: X, v2: Y) String {
    return v1 + v2
}
fn main() {
    let v1 = add[String, uint]("5", 10)
    // v1 = "510"
    let v2 = add[uint, uint](5, 10)
    // v2 = "15"
}
```

- Generic type names are usually a single upper-case letter such as `T`, but any identifier works
- Generic types can be modified: e.g. If `T` is `String`, then `?T` will become `?String`

The compiler can also infer a generic type from an argument by prefixing the type parameter with `$`:

```rust
fn combined_length(v1: $V1, v2: $V2) uint {
    #if V2.$is_nullable
    return v1.length
    #else
    return v1.length + v2.length
    #end
}
```

In other words, `fn myfunc[T](arg: T)` can be written as `fn myfunc(arg: $T)` when `T` should be inferred from `arg`.
After `$T` introduces `T`, later parameters and the return type use `T` as usual,
and `$T` may also sit inside a type: `?$T`, `&$T`, `&[$T]`, `stack $T`, `*$T` and
class arguments such as `Array[$T]` or `HashMap[$K, $V]` infer `T` through that
wrapper. A `?$T` parameter also takes a plain value. A nullable variable that was
just checked with `isset` infers its plain type, as it would pass to a plain parameter.

```rust
fn pair(a: $T, b: T) T { return a + b }
fn first(items: Array[$T]) T { return items.get(0) !! }
fn unwrap(value: ?$T) T { return value ?? panic("missing") }
```

## Modes

Use `mode` to wrap an existing class and change its behavior. A mode cannot add
properties and remains implicitly compatible with its base type in both
directions. When overloads or operator hooks accept both types, the exact static
type passed at the call site wins.

```rust
mode LowerCaseString for String {
    fn equals(cmp: LowerCaseString) bool $eq {
        return this.lower() == cmp.lower()
    }
    fn hash() uint $hash {
        return this.lower().hash()
    }
}

fn main() {
    let a : String = "HELLO"
    let b : LowerCaseString = "HELLO"
    println(a == "hello") // False
    println(b == "hello") // True
}
```

`$add` and `$sub` customize `+` and `-` (and `+=`, `-=`) for a class; the method takes the right-hand value and returns the result. `$eq` customizes `==`. Types used as `HashMap` keys must also define `$hash`, and equal values must produce the same hash. `Array.unique()` already honours `$eq`; without `$hash`, a map would bucket by the built-in hash and break that invariant.

Generic specializations remain distinct and invariant even when their type
arguments are a compatible mode/base pair. For example, `Array[LowerCaseString]`
cannot be assigned to `Array[String]`, and `HashMap[LowerCaseString, V]` cannot
be assigned to `HashMap[String, V]`.

An enum's generated default is its first declared member. Assign another declared
member to change an enum value. Arithmetic produces the underlying numeric type;
increment, decrement, and compound assignment are not supported on enum variables.
An enum only compares with values of the same enum: `color == 0` or
`Color.red == Other.x` is a compile error; convert first with `color.to(int)`.
For an enum backed by a fixed array, `&EnumType` borrows one complete enum value;
use `borrowed[0]` to read or replace that value. Fields and elements of an inline
enum can be read, but cannot be modified or borrowed separately. Methods must
leave that storage unchanged and must not expose a writable alias. Copy to the
underlying type before modifying its fields or calling a mutating method.

## Traits

A trait is a set of methods that classes and structs can copy into their own
body with `use`. Traits can be generic.

```rust
trait Greeter {
    fn greet() String {
        return "Hello " + this.name
    }
}
trait Wrapper[T] {
    fn wrap(value: T) Array[T] {
        return Array[T]{ value }
    }
}

class Person {
    name: String
    use Greeter
    use Wrapper[String]
}

fn main() {
    let p = Person { name: "Ada" }
    println(p.greet())          // Hello Ada
    println(p.wrap("x").length) // 1
}
```

## Finalizers

A class may define `gc_free()` to release raw or native resources when the GC
reclaims it. Its `this` value is borrowed and cannot be stored or captured, so
the object cannot be resurrected. A finalizer takes no arguments, returns
`void`, cannot throw errors, allocate GC-managed objects, recursively collect,
or call code with unknown allocation effects. `panic` remains allowed.

Finalization order is unspecified. A finalizer must not access other
GC-managed objects or acquire locks, and shared finalizers may run on any
collecting thread. Use an explicit operation such as `close()` for deterministic
or ordered cleanup.


## Globals

```rust
global my_global : uint          // Global (recommended)
shared my_shared_global : uint   // Global shared over all threads
global my_counter : uint (my_start + 1)   // Optional default value
```

Defaults run before `main`, each after the globals it reads (directly or through the functions it calls), whatever the declaration order; two defaults that read each other are a compile error.

A `shared` global is read as `shared T`, so it follows the [data race](#data-races) rules: integers are atomic, objects are read-only views, and mutable state goes in a `Lock`. `@shared` is the unsafe form that reads as plain `T` and is not checked.

## Aliases

Three declarations give an existing thing a new name in the current scope. Add `$global` to make the name available in every namespace without a prefix.

```rust
use valk.fs

alias Path for fs.Path            // Another name for a class, function or namespace member
type Handler (fn(String)(bool))   // A name for a type expression
value MAX_ITEMS (64 * 4)          // A compile-time constant

fn main() {
    let dir: Path = "."
    let ok: Handler = fn(s: String) bool { return s.length > 0 }
    println(MAX_ITEMS) // 256
}
```

## Tokens

### If Else

```rust
if a == b : ...code...     // Single line
if a == b { ...code... }
else if a == c { ... }
else { ... }
let c = a == b ? "true" : "false"  // inline
```

### While

```rust
let x = 0
while x++ < 5 {
    // 1 - 5
    if x == 1 : continue
    if x == 4 : break
    print(x)
}
// output: 2 3
```

### Each

```rust
let m = Map[String]{};
m.set("a", "10")
m.set("b", "20")
m.set("c", "30")
each m as value, key {
    println(key + ":" + value)
}
// a:10 b:20 c:30
each m as v {
    println(v)
}
// 10 20 30
```

## Null-checking

Before using a nullable value such as `?String`, check that it is not `null`.

```rust
fn print(msg: ?String) {
    println(msg) // Compile error
    // Instead we do:
    // Option 1
    if isset(msg) : println(msg)
    // Option 2
    println(msg ?? "alternative-msg")
    // Option 3
    println(msg ?! return)
    // Option 4
    if !isset(msg) : return
    println(msg)
}
```

## Files

API for [valk.fs](api.md#fs)

Use `valk.fs` for file-system operations.

`fs.stat(path)` returns a `FileInfo` with `size` in bytes, `kind` (`file`,
`directory`, or `other`), `permissions`, and `modified_time` in Unix nanoseconds.
It follows symlinks and reports an error if the target cannot be read.
Permissions use Unix mode bits; on Windows they reflect the read-only attribute
(`0c444` or `0c666`, plus `0c111` for directories), not ACL permissions.

`fs.read_dir(path)` reads one entry name at a time, without collecting the entire
directory. It skips `.` and `..`, does not recurse, and returns names in no
guaranteed order. `next()` returns null at the end and propagates read errors.
The iterator closes automatically at the end; close it when stopping early:

```rust
let entries = fs.read_dir("assets") ! panic("open directory")
defer entries.close() ! panic("close directory")
while true {
    let name = entries.next() ! panic("read directory")
    if !isset(name) : break
    println(name)
}
```

Use `fs.files_in()` when you want an array of paths or recursive listing.

`OpenOptions.write` defaults to null, which disables writing. Choose
`fs.WriteMode.preserve` to overwrite bytes without clearing the file,
`fs.WriteMode.truncate` to clear it on open, or `fs.WriteMode.append` to write at
the end even after seeking. `read` defaults to true; `create` allows creating a
missing file, and `exclusive` with `create` rejects an existing file.

Streams share the `io.Reader`, `io.Writer`, `io.Seeker` and `io.Closer` interfaces
from [valk.io](api.md#io). `fs.FileStream` implements all four, `net.Connection` is a
reader, writer and closer, `ByteReader`
reads from a `String`, `ByteBuffer` or `&[u8]`, and a `ByteBuffer` is a
writer that collects everything written to it. `io.copy` moves everything from a reader
into a writer:

```rust
let file = fs.stream("out.txt", fs.OpenOptions { read: false, write: fs.WriteMode.truncate, create: true }) ! panic("open")
io.copy("hello".reader(), file) ! panic("copy")
file.close() ! panic("close")
```

For floating-point text, use `write_f64_ascii_shortest` for the shortest
round-trip representation, or `write_f64_ascii` with an explicit number
of decimal places. Set `trim_zeros` to `true` to remove trailing fractional
zeros. `write_f64_le` and `write_f64_be` write binary bytes.

```rust
let buffer = ByteBuffer.new()
buffer.write_f64_ascii_shortest(1.5) // 1.5
buffer.write(" ")
buffer.write_f64_ascii(1.5, 3) // 1.500
```

The process' standard streams are available as `io.stdin()` (a reader),
`io.stdout()` and `io.stderr()` (writers). Their reads and writes block:

```rust
// Save everything piped into the program
io.copy(io.stdin(), file) ! panic("copy")
io.stderr().write("done\n") ! panic("write")
```

`io.LineReader` reads any reader line by line. `read_line()` returns the next
line without its `\n` or `\r\n` and null once the input is exhausted,
`read_until(delimiter)` splits on any byte, and `lines()` collects what remains:

```rust
let input = io.LineReader.new(io.stdin())
while true {
    let line = input.read_line() ! panic("read")
    if !isset(line) : break
    println(line)
}
```

Environment variables are read with `core.getenv(name)`, and changed for the
process and its children with `core.setenv(name, value)` and `core.unsetenv(name)`.

## Paths

Valk offers a `Path` mode for `String` which can be initialized by either `type hints` or using `fs.path("path")`

```rust
use valk.fs

fn main() {
    let path : fs.Path = "."
    path = path.add("folder1").add("folder2/").add("/file") // Adding parts to a path without worrying about double slashes
    println(path) // ./folder1/folder2/file
    path = path.resolve()
    println(path) // /var/www/folder1/folder2/file
    path = path + ".txt"
    println(path) // /var/www/folder1/folder2/file.txt
    path = path.pop()
    println(path) // /var/www/folder1/folder2
}
```

## JSON

API for [valk.json](api.md#json)

```rust
use valk.json

let document = json.decode("{\"name\":\"Alice\",\"age\":30}") ! panic("Invalid JSON")
let name = document.get_string("name") ! panic("Missing name")
let age = document["age"].int
document = document.set_bool("active", true)
println(json.encode(document))
```

Objects use string keys and arrays use integer indexes. The same operations work for either:

```rust
let first_name_str = document["names"][0].string // Fast lookup
let first_name_str = document.get("names").get(0).string // Same but longer
// Get offsets and it must exist
let first_name = document["names"].get_required(0) ! panic("Missing item")
// Get offsets while also making sure the type matches
let first_name_str = document["names"].get_string(0) ! panic("Missing item or is not a string")
// Explicit
let list = document.get_required("names") ! panic("Missing names list")
let name = list.get_required(0) ! panic("Missing item")
let name_str = name.string_value() ! panic("Json value must be a string")
```

`json.from(value)` converts any value to a json.Value.
`value.to_type[T]()` converts json.Value back to a Valk type and returns an
error when the document does not match that type. Every field of `T` must be
present unless it is nullable or declares an explicit default `(value)`.

```rust
class User {
    name: String
    age: int
}

// Json string -> json.Value
let json_user = json.decode("{\"name\":\"Alice\",\"age\":30}") ! panic("Invalid json")
// json.Value -> User
let user = json_user.to_type[User]() ! panic("Incompatible")
// User -> json.Value
let json_usr = json.from(user)
// json.Value -> json string
let json_string = json_usr.encode()
```

You can also decode directly to a type using `json.decode_to[T](text)`

```rust
class User {
    name: String
    age: int
}

let user = json.decode_to[User]("{\"name\":\"Alice\",\"age\":30}") ! panic("Invalid user")
```

## DateTime

API for [valk.time](api.md#time)

`time.DateTime` represents UTC dates from year 1 through 9999 with microsecond
precision. Constructor components are optional and default to the current time.
Constructors and changes throw a `LookupError` (`.range`) when the result is not
a valid date or falls outside the supported range.

```rust
use valk.time

// Init
let now = time.DateTime.now()
let datetime = time.DateTime.new(2026, 8, 8, 19, 7, 6, 123_456) ! panic("Invalid date")
let from_str = time.DateTime.from_format("Y-m-d H:i:s.u", text) ! panic("Invalid date")

// Change
let changed = datetime.add_days(1) !? datetime // Returns a new DateTime
datetime.modify_add_hours(2) _                 // Modifies the existing object

// Format to string
let text = datetime.format("Y-m-d H:i:s.u")
println(datetime.to_iso8601())
println(datetime) // Defaults to to_iso8601 string
```

`with_*` and `add_*` methods return a new object. Methods starting with
`modify_` update the existing object. Format tokens are `Y` (year), `m`
(month), `d` (day), `H` (hour), `i` (minute), `s` (second), `v`
(milliseconds), and `u` (microseconds).

## Coroutines

Coroutines let multiple functions make progress on one thread.

```rust
let request_1 = co http.request("GET", "http://some-website/api/endpoint1")
let request_2 = co http.request("GET", "http://some-website/api/endpoint2")
let response_1 = await request_1 !? http.Response.empty(400)
let response_2 = await request_2 !? http.Response.empty(400)
```

Use `co` to start a coroutine and `await` to wait for its result.
Coroutine error types cannot contain payload fields, including inherited fields.
Handle payload errors inside the coroutine or encode them in its return type.
An error thrown by a coroutine reaches the `await`; a coroutine that is never
awaited drops its error silently.

```rust
fn hi() { println("Hello") }
fn main() {
    let task = co hi()
    await task
}
```

Every coroutine runs on its own 1 MB stack; `main` gets 8 MB. Exhausting it, for example with very deep recursion, ends the program with a `Stack overflow` panic; keep large buffers on the heap.


## Channels and cancellation

API for [valk.sync](api.md#sync)

A `Channel` moves values between coroutines, on one thread or across threads.
`send` waits while a bounded channel is full, `recv` waits for a value, and
both take an optional timeout and cancellation token. Closing a channel lets
receivers drain what is queued and then fail with `closed`; `each` receives
until then. Class values must be `shared` to travel: a literal passed to
`send` is published on the spot, a named value has to be converted first.

```rust
use valk.sync
use valk.thread

class Job {
    id: uint
}

fn main() {
    let jobs: shared sync.Channel[shared Job] = sync.Channel[shared Job].new(16) ! panic("init")
    let results: shared sync.Channel[uint] = sync.Channel[uint].new() ! panic("init")

    let worker = thread.start(fn() {
        each jobs as job {
            results.send(job.id * 2) ! break
        }
    }) ! panic("thread")

    jobs.send(Job { id: 1 }) ! panic("closed")
    jobs.send(Job { id: 2 }) ! panic("closed")
    jobs.close()
    let total = (results.recv(1000) !? 0) + (results.recv(1000) !? 0)
    worker.await()
    println(total) // 6
}
```

`try_send` and `try_recv` never wait and fail with `full` or `empty`.

A `CancelToken` is a shared flag with waiters. `cancel()` wakes every
`wait()`, cancels every token made with `child()`, and runs the callbacks
given to `on_cancel`. `cancel_after(ms)` cancels from a timer on the calling
thread. A blocked `send` or `recv` given the token ends with `cancelled`:

```rust
let stop: shared sync.CancelToken = sync.CancelToken.new() ! panic("init")
stop.cancel_after(500)
let value = queue.recv(0, stop) ! {
    if error_is(E.code, cancelled) : println("gave up")
    return
}
```

A token also reaches socket I/O. `Connection.set_cancel(token)` interrupts a
read or write that is blocked when the token is cancelled, and every later
one; they throw the `cancelled` I/O error. The registration is dropped by
`close()`, so close the connection before the token outlives it:

```rust
let con = listener.accept(3000) ! return
con.set_cancel(stop)
let buffer = [u8]{ 0 x 1024 }
let bytes = con.read(buffer) ! {
    if error_is(E.code, cancelled) : println("cancelled")
    con.close() ! {}
    return
}
```

## Signals

API for [valk.signal](api.md#signal)

`valk.signal` delivers SIGINT, SIGTERM and the other process signals without
running anything in signal context: the handler writes the number to a pipe
and a dispatcher thread does the work. A signal can cancel tokens, run
callbacks, or wake a coroutine waiting for it. `cancel_on_shutdown` watches
the signals a service gets when it is asked to stop, which together with
`Server.shutdown` gives a graceful stop on Ctrl-C or `kill`:

```rust
use valk.signal
use valk.sync
use valk.http

fn main() {
    let stop: shared sync.CancelToken = sync.CancelToken.new() ! panic("init")
    signal.cancel_on_shutdown(stop) ! panic("signals")

    let server = http.Server.new("127.0.0.1", 8080, handler)
    let running = co server.start()
    stop.wait()
    server.shutdown()
    await running ! panic("server failed")
}
```

`wait(sig, timeout_ms)` blocks the current coroutine until the signal
arrives, `ignore` and `restore` set the OS disposition, and `raise` sends a
signal to the process itself. `hangup`, `quit`, `user1` and `user2` throw
`unsupported` on Windows, where only `interrupt` and `terminate` exist.

## Access types

Declarations without a marker are available throughout their package and
private outside it. Use `-` to keep a declaration in its source file, `~` to
make it read-only outside that source, and `+` to make it public everywhere.

Markers containing `~` are only allowed on properties and globals. Other
declarations use no marker, `-`, `-+`, or `+`.

Combined markers widen as code gets closer to the declaration. They use `-`,
`~`, `+` in that order:

- `~+` is public in its namespace and read-only elsewhere.
- `-~` is read-only in its namespace and private elsewhere.
- `-+` is public in its namespace and private elsewhere.
- `-~+` is public in its namespace, read-only in its package, and private
  outside the package.

```rust
fn helper() {}       // Available in this package
- fn internal() {}   // Available only in this source file
-+ fn ns_helper() {} // Available only in this namespace
+ fn public_api() {} // Available everywhere

class Config {
    value: int         // Available in this package
    - secret: String   // Available only in this source file
    ~ version: String  // Read-only outside this source file
    ~+ state: uint     // Read-only outside this namespace
    + name: String     // Available everywhere
}
```

`-` is source-private rather than class-private: other code in the same file
can still access the declaration.

Low-level code can place `@ignore_access` in a scope to bypass access checks.

## Value scopes

With `value scopes` we can execute code that eventually returns a value.

```rust
let a = 5
let b = <{
    println("Add 10")
    return a + 10
}
println(b) // 15
```

This feature is very useful in error handling for when we want to provide an alternative value but also want to execute some code when it happens. e.g. for logging.

```rust
let a = might_error() !? <{
    Mylogger.log("might_error() returned an error, this should not happen!")
    return 0
}
```

## Compile macros

Compile macros select code using compiler definitions or type metadata. Built-in definitions include `OS`, `ARCH`, and `TEST`; additional values can be supplied with `--def`.

Source expressions `__PATH__`, `__FILE__`, `__DIR__`, and `__LINE__` expand to the current source path, the path relative to its package source directory, the current source directory, and the one-based source line. They are also recognized by `is_defined`.

```rust
fn main() {
    #if OS == "linux"
    println("Linux")
    #elif OS == "macos"
    println("macOS")
    #else
    println("Not macOS or Linux")
    #end

    #if T.$is_pointer
    println("Type is a pointer")
    #end
    #if T.$is_gc
    println("Type is a garbage collected type")
    #end
}
```

## Atomics

We can do atomic operations on integers and floats by placing our operation inside an `atomic()` token. This also works on number properties of `shared` data.

```rust
// {value-before-updating} = atomic( {variable} {op} {value} )
let v = 5
let a = atomic(v + 2)
println(a) // 5
println(v) // 7
```

## Testing

To test a project, pass `--test` with the build command. Test declarations are omitted from ordinary builds; in a test build, the generated entry point runs them instead of `main`. Use `assert` inside a test to record its results.

```rust
test "My test" {
    let a = 10
    assert(a > 5)
    assert("this" == "that")
}
```

Regular `test` declarations run concurrently. After every regular test has finished, `synctest` declarations run sequentially:

```rust
test "Can run concurrently" {
    // This may overlap with other regular tests.
}

synctest "Requires isolation" {
    // No other test is running while this test executes.
    // Use this for tests that modify globals, collect garbage, or depend on
    // other process-wide state.
}
```

All regular tests run before any `synctest`, regardless of their declaration order. Synctests then run one at a time in their declaration order. A test that needs to verify concurrency can still create and await its own coroutines.

```sh
valk build src/*.valk --test --run
```

Or we can put our tests in a different directory.

```sh
valk build src/*.valk ./my-tests/*.valk --test --run
```

Use `--filter` to compile only tests whose names contain a string:

```sh
valk build ./src ./tests --test --filter "database" --run
```

## HTTP

API for [valk.http](api.md#http)

### HTTP Client

With `valk.http` you can send HTTP requests or download files from a URL.

```rust
// Send basic request
let res = http.request("GET", "http://some-website/api/endpoint") ! panic("Request failed")

// Send GET request with data
let data = Map[String]{ "key1" => "val1" }
let res = http.request("GET", "http://some-website/api/endpoint", http.Options{ query_data: data }) ! panic("Request failed")

// Send POST request with data
let json_data = json.from(Map[String]{ "key1" => "val1" })
let res = http.request("POST", "http://some-website/api/endpoint", http.Options{ body: json.encode(json_data) }) ! panic("Request failed")

// Download file
http.download(url, to_path) ! panic("Failed to download file")

// Stream the response body into any io.Writer instead of keeping it in memory
let out = fs.stream(to_path, fs.OpenOptions { read: false, write: fs.WriteMode.truncate, create: true }) ! panic("Failed to open file")
http.request("GET", url, http.Options{ output: out }) ! panic("Request failed")
out.close() ! panic("Failed to close file")
```

Header names are case-insensitive. `get` returns the first value or a lookup
error; `get_all` returns all values in order (an empty array when absent).
`set` replaces all values for a name, while `append` adds a separate field.
Iteration yields each value and name, including repeated fields.

```rust
let headers = http.Headers { "Accept" => "application/json" }
headers.append("X-Tag", "first").append("x-tag", "second")
let res = http.request("GET", url, http.Options { headers: headers }) ! panic("Request failed")
let cookies = res.headers.get_all("Set-Cookie")
```

### HTTP Server

```rust
use valk.http

fn handler(req: http.Request) http.Response {
    return http.Response.html("Hello world!")
}

fn main() {
    let s = http.Server.new("127.0.0.1", 9000, handler)
    s.show_info = true
    s.start() ! { println("Failed to start http server"); return }
}
```

`start` runs until shutdown. Use `co` to keep doing other work:

```rust
let running = co s.start()
// Other work...
s.request_shutdown(5000)
await running ! { println("HTTP server failed") }
```

`start` takes a worker thread count and defaults to the number of CPU threads.
`request_shutdown(5000)` allows up to five seconds for current requests to finish.

HTTP/2 support is experimental and opt-in. Configure TLS before starting:

```rust
s.tls("certificate.pem", "private-key.pem") !!
s.http2 = true
s.start() !!
```

HTTP/2 uses the same request handlers and responses, with HTTP/1.1 fallback.
It currently requires TLS and the regular handler API, not `fast` handlers.

HTTP/1.0 clients are served as well: a `Host` header is not required, the
connection closes after the response unless the request says
`Connection: keep-alive`, and responses always carry a `Content-Length`. A
1.0 request with a `Transfer-Encoding` header is rejected with 400, since
transfer codings do not exist in that version. Higher `HTTP/1.x` minor
versions are handled as 1.1. A `Connection: close` on an HTTP/1.1 request
ends the connection after that response; anything pipelined behind it is
not served.

## Sockets

API for [valk.net](api.md#net)

TCP servers and clients, and UDP sockets. Hosts can be names, IPv4
addresses or IPv6 addresses (`"::1"`, or `"[::1]"` as written in a URL);
a name that resolves to both uses IPv4. A server bound to `"::"` also
accepts IPv4 clients where the system allows it.

Example

```rust
use valk.net

// Server
fn server() {
    let sock = net.Socket.server(net.SocketType.tcp, "127.0.0.1", 8000) ! panic("Failed to open socket")
    let buffer = [u8]{ 0 x 1000 }
    while true {
        let con = sock.accept() ! {
            println("# Failed to accept connection")
            continue;
        }
        // Handle connection (normally you do this on a separate coroutine so you can keep accepting new connections)
        while true {
            let bytes = con.read(buffer) ! {
                if error_is(E.code, closed) : break // Connection closed
                println("# Server failed to read from connection")
                break
            }
            println("# Server received: " + buffer.view(0, bytes).to_string())
            con.write("PONG") ! {
                println("# Server failed to send data")
                break
            }
        }
    }
}

// Client
fn main() {
    // Start our server in the background
    let s = co server()
    // Open client
    let con = net.Socket.client(net.SocketType.tcp, "127.0.0.1", 8000) ! panic("Failed to open socket")
    // Send
    con.write("PING") ! panic("Client failed to send data")
    // Recv
    let buffer = [u8]{ 0 x 1000 }
    let bytes = con.read(buffer) ! panic("Client failed to read from connection")
    println("# Client received: " + buffer.view(0, bytes).to_string())
    con.close() ! panic("Failed to close connection")
}
```

UDP example

```rust
use valk.net

fn main() {
    let server = net.UdpSocket.bind("127.0.0.1", 8001) ! panic("Failed to bind")
    let client = net.UdpSocket.open() ! panic("Failed to open socket")

    let to = net.SocketAddress.parse("127.0.0.1", 8001) ! panic("Invalid address")
    client.send_to("PING", to) ! panic("Failed to send")

    let buffer = [u8]{ 0 x 1500 }
    let bytes, from = server.recv_from(buffer) ! panic("Failed to receive")
    println("# Server received " + buffer.view(0, bytes).to_string() + " from " + from.to_string())
    server.send_to("PONG", from) ! panic("Failed to send")
}
```

`recv_from` and `send_to` time out after `read_timeout_ms` / `write_timeout_ms`
(5000 by default). `bind` with port 0 lets the system pick a port;
`local_address()` returns it. `SocketAddress.resolve(host, port)` looks a
name up; `parse` only accepts numeric addresses.

## Templates

`valk.template` is a small runtime template engine.

Example template:

```html
<html>
    <head></head>
    <body>
        @include("header.html")

        <h1>{{ title }}</h1>

        @each(articles as art)
        <h2>{{ art.title }}</h2>
        <p>{! art.content !}</p>
        @end
    </body>
</html>
```

How to render:

```rust
use valk.template
//
class Article {
    title: String
    content: String
}
class PageData {
    title: String
    articles: Array[Article]
}
//
fn main() {
    // Embed templates at compile time and register them by relative path.
    template.set_content_many(#embed_dir("views"))
    // Template data
    let data = PageData {
        title: "Hello world"
        articles: Array[Article]{
            Article {
                title: "Article 1"
                content: "Some content"
            }
        }
    }
    // Render the template
    let result = template.render("example.html", data) ! panic("Template error: %{E.message}")

    println(result)
}
```

Template engine tokens:

```
@if(...) @elif(...) @else @end

@each(... as val) @end // Loop over array or map
@each(... as val, key) // With key
@each(... as val, key, index) // With key & index

{{ }}   // Print an HTML-escaped value (or use the configured escape function)
{! !}   // Print a raw value without escaping

@include("...") // Include another template registered with set_content/set_content_many
```

Note: `valk.template` works at runtime and therefore cannot detect incorrect template syntax at compile time.

## Crypto

Supported utilities include bcrypt, BLAKE2b, Base64, MD5, SHA-1, SHA-256,
SHA-384, SHA-512, HMAC, PBKDF2, HKDF, and secure random values.

```rust
use valk.crypto

let hash = crypto.Blake2b.hash_string("test") ! panic("Failed to hash")
let hex = crypto.sha512_encode("test")
```

The hash functions share the `Hasher` interface: `update` feeds input in
pieces and `finish` writes the digest. `crypto.hash` and `crypto.hash_hex`
take a `HashAlgorithm` and do it in one call; `hex_encode` and `hex_decode`
convert raw digests:

```rust
use valk.crypto

let sha = crypto.hasher(crypto.HashAlgorithm.sha256)
sha.update("ab")
sha.update("c")
let digest = [u8]{ 0 x sha.digest_size() }
sha.finish(digest)
println(crypto.hex_encode(digest)) // same as crypto.sha256_encode("abc")
```

`Hmac` signs and verifies messages with any of those hashes. Compare MACs
and tokens with `verify` or `constant_time_equals`, never with `==`:

```rust
use valk.crypto

let signature = crypto.Hmac.sign_hex(crypto.HashAlgorithm.sha256, "secret", payload)
if !crypto.Hmac.verify(crypto.HashAlgorithm.sha256, "secret", payload, received) {
    println("bad signature")
}
```

`pbkdf2` turns a password into a key of any length, and `hkdf` derives keys
from material that already has entropy, such as a shared secret:

```rust
use valk.crypto

let key = crypto.pbkdf2(crypto.HashAlgorithm.sha256, password, salt, 600000, 32) ! panic("bad input")
let session = crypto.hkdf(crypto.HashAlgorithm.sha256, secret, "", "session v1", 32) ! panic("bad input")
```

Password hashing/verify example:

```rust
use valk.crypto

fn main() {
    let password = "test"
    let hash = crypto.bcrypt_hash(password) ! panic("Failed to hash password")
    if crypto.bcrypt_verify("test", hash) {
        println("👍")
    } else {
        println("❌")
    }
}
```

## Compression

API for [valk.compress](api.md#compress)

DEFLATE, zlib and gzip compression, plus the CRC-32 and Adler-32 checksums.
zlib is DEFLATE with a small header and an Adler-32 trailer (what HTTP calls
`deflate`); gzip adds a header and a CRC-32 trailer (`.gz` files, HTTP `gzip`).

```rust
use valk.compress

fn main() {
    let text = "hello hello hello hello"
    let packed = compress.gzip(text)          // also: deflate(), zlib()
    let unpacked = compress.gunzip(packed) ! panic("Corrupt data") // inflate(), unzlib()
    println(unpacked == text)

    let crc = compress.crc32("123456789")      // 0xcbf43926
    let adler = compress.adler32("Wikipedia")  // 0x11e60398
}
```

Levels run from 0 (store only) to 9; the default is 6. Decompression takes an
optional `max_size` to bound the output of untrusted data. Streams of any size
go through `Compressor` (an `io.Writer`) and `Decompressor` (an `io.Reader`):

```rust
use valk.compress
use valk.fs
use valk.io

fn main() {
    let file = fs.stream("log.txt.gz", fs.OpenOptions { read: false, write: fs.WriteMode.truncate, create: true }) ! panic("Cannot open")
    let writer = compress.Compressor.new(file, compress.Format.gzip)
    writer.write("first line\n") ! panic("Write failed")
    writer.close() ! panic("Write failed") // writes the last block and the trailer
    file.close() ! panic("Close failed")

    let input = fs.stream("log.txt.gz") ! panic("Cannot open")
    let reader = compress.Decompressor.new(input, compress.Format.gzip)
    let text = io.read_all(reader) ! panic("Corrupt data")
}
```

## Embed

With `#embed` & `#embed_dir` you can embed files/assets into your code as strings at compile time. All paths are relative to your `valk.json` config.

```rust
fn main() {
    let content = #embed("views/page1.html")
    println(content)
    let files = #embed_dir("views")
    each files as content, filename {
        println(filename)
    }
    // Example output:
    // page1.html
    // sub-dir/page2.html
    // sub-dir/page3.html
}
```

Note: `#embed_dir` is recursive. Also try to put an embed in a separate function if you need it in multiple places. Embedding the same file in multiple places is a waste of spaces and results in a larger binary size.

## Namespaces

Each directory in a project represents a namespace. Create a `valk.json` file
at the project root; source code goes in `./src` by default.

```
./valk.json
./src
  | main.valk
  > ./ns1
    | MyClass.valk
  > ./ns2
    | MyOtherClass.valk
```

```rust
// main.valk
use ns1
use ns2

fn main() {
    let a = ns1.MyClass {}
    let b = ns2.MyOtherClass {}
}
```

```sh
valk build ./src -o ./myprogram
```

Use `--lint` to check every source in a package without requiring `main` or
producing an executable:

```sh
valk build ./src --lint
```

## Unsafe

Although Valk aims to be safe, it still supports low-level operations when needed. Unsafe features include:

- Calling a function with a `ptr` argument
- Offset access on unbounded pointers

Tokens that start with `@`, such as `@ptrv`, `@ref`, and `@cast`, do not by
themselves require an unsafe scope. `@ref(x)` is the address of `x` as a
raw `ptr`, except when `x` is a struct held inline (a local or a struct
property): then it is the typed `*Struct` pointer, so the struct's methods
are reachable through it, and it still converts to `ptr` and `*[Struct]`.

Place `@unsafe` in a scope to use these features in that scope and its child scopes:

```rust
fn first(data: *[u8]) u8 {
    @unsafe
    return data[0]
}
```

Use `valk build --ignore-unsafe` to allow them for an entire build.

## Structs

A `struct` is an inline value type. Assignment, argument passing, and returning
a struct copy all of its fields by value. A struct initializer such as `.{}`
never allocates manual storage. Use `mem.new[T]()` when a struct must live in a
manual heap allocation, and release it with `mem.free`.

```rust
struct MyStruct {
    a: i32
    b: i32
}

fn main() {
    let first = MyStruct{
        a: 5
        b: 100
    }
    let second = first
    second.a = 10

    println(first.a)  // 5
    println(second.a) // 10

    @unsafe // mem.free takes a raw pointer
    let pointer = mem.new[MyStruct](.{ a: 5, b: 100 })
    defer mem.free(pointer)
}
```

## External libraries

To bind with external libraries we have to do 2 things:

- Define the external functions/globals we want to import
- Link with the library

Defining extern symbols is done by using the `extern` keyword

```rust
extern fn malloc(size: uint) ptr;
extern fn free(adr: ptr);
```

C-style variadic declarations use `...` as the final argument. Variadic
arguments are supported only on `extern` functions; ordinary and exported Valk
functions cannot declare them.

```rust
extern fn printf(format: cstring, ...) i32;

fn main() {
    @unsafe
    let count: i32 = 7
    printf("\%d \%f\n".data_cstring, count, 1.5)
}
```

Variadic arguments keep their own type and follow the C promotion rules
(`f32` becomes `double`, small integers become `i32`); only integers, floats
and raw pointers can be passed.

## Linking

To link with your library you have 2 options:

- Define the link information inside your code
- Use command line arguments `-L` and `-l`

Option 1: Inside the code

```rust
link "mylib" // Will link with libmylib.so/.a/.dll/.lib/.dylib/.tbd
link [dynamic|static] "mylib" // Optional: you can force it to link static or dynamic
link ":mylib.a" // use ':' the specify the exact name. This will link with `mylib.a`
```

Option 2: Use CLI arguments

```bash
# This will look for libmylib.so in all library directories. It will also add "/usr/my-libs" to that set of directories.
valk build src/*.valk -l mylib -L "/usr/my-libs"
valk build src/*.valk -l mylib -L "/usr/my-libs" --static
```

## Building native libraries

To make a Valk function callable by a native linker, mark it `export`. Exported
functions must have concrete, non-generic signatures. Arguments and return types
cannot contain GC-managed data; use an explicit raw-pointer protocol instead.

```rust
export fn add(left: int, right: int) int {
    return left + right
}
```

Build those exported functions into a library with `--lib`. A library has no
executable entry point, so it does not need `fn main()`.

```bash
valk build src/*.valk --lib -o libmylib
```

This produces a shared library: `libmylib.so` on Linux,
`libmylib.dylib` on macOS, or `libmylib.dll` on Windows. Its automatic
dependencies are linked dynamically.

Use `--static-lib` to produce a static archive instead. The archive leaves
automatic dependencies for the final consumer to link dynamically.

```bash
valk build src/*.valk --lib --static-lib -o libmylib
```

The output is `libmylib.a` on Linux and macOS, or `libmylib.lib` on Windows.
Use `--static` to link dependencies statically. With `--static-lib`, those
dependencies are folded into the archive:

```bash
valk build src/*.valk --lib --static-lib --static -o libmylib
```

## Valk manager

The valk manager aka `vman` can be used to install/update new versions of `valk`. It is also used to install packages for your project.

```sh
vman use latest # Will install/use the latest version of valk
vman use # Will install/use the valk version defined in your {cwd}/valk.json config -> { "use": "x.x.x" }
vman use {version} # Install/use a specific version
vman install # Install packages defined in valk.json
vman install {pkg} # Install a package in the current project
vman remove {pkg} # Remove a package
```

Project: [Link](https://github.com/valk-lang/vman)

## Data races

`shared T` is a read-only view used to pass data across threads. Only number and bool properties can be changed through that view, integers with atomic access; every other store, and every method that performs one on data reached from its receiver, is rejected. The view carries over to everything read through it, including struct properties, their methods, and the elements of slice properties. A method marked `@threadsafe` opts out of that check because it synchronizes on its own, like `Mutex.lock()`. Elements of a shared array of plain values can be assigned with `values[i] = x`, which is an atomic store; the array cannot grow or shrink through the view. Converting `T` to `shared T` requires its complete reachable object graph to be unique: nothing else may still name any part of it, including values that were moved into it earlier with a store, an initializer or a call such as `append`. Creating the view consumes that uniqueness, and every ordinary variable that named part of the graph is unusable afterwards; the check follows control flow, so a value published on one path stays usable on paths where it was not, and loops are checked for aliases made in an earlier iteration. Publishing the result of a call consumes the arguments it was built from. A shared view cannot be converted back to `T`; `.@cast(T)` is the unsafe escape hatch.

### Mutable shared data

`Lock[T]` holds a value that threads may change. The value is only reachable inside a `lock` block, which holds the lock's mutex until the block ends:

```rust
class Stats {
    count: uint (0)
    names: Array[String] (.{})
}

let stats: shared Lock[Stats] = .new(Stats {}) !!

lock stats as s {
    s.count++
    s.names.append("x")
}
```

Inside the block `s` is a `locked Stats`: a mutable view that is valid until the block ends. Anything read through it, like `s.names`, is a locked view too. The block releases the lock on every exit, including `return`, `throw` and `!>`. `break` and `continue` cannot leave a lock block.

A locked view cannot escape the block: it cannot be returned past the block, captured by a closure, handed to a coroutine, stored in a property or global, or assigned to a variable declared outside the block. Moving data around inside the locked graph, like `s.items.append(s.first)`, is allowed. Functions can take and return `locked T` views while the originating lock is held. Data stored into locked data must be a unique graph, the same rule as for `shared` conversions, and it is published with the lock. Data from one lock cannot be stored under another lock. Independent copies made with `$clone` or `.clone()` may leave the block. A custom clone hook that returns the original data keeps its result locked.

Methods that hand elements to a callback or return a view of the elements, like `sort(comparator)`, `filter` and `view()` on a locked array, cannot be called on locked data: the callback or view could keep an element past the block. The error points at the call with a note that the method was checked for a locked receiver. Sort or filter a copy instead, or loop over the elements inside the block.

`T` must be a class type. Waiting for the lock yields to other coroutines on the thread, like `core.Mutex`. The lock is not reentrant: locking the same `Lock` again from the same thread deadlocks. Reading the value outside a `lock` block is not possible; every reader takes the lock too. A thread whose entry function returns while one of its coroutines is still inside a `lock` block keeps running its coroutines until that block ends.
