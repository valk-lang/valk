
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
* [Globals](#globals)
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

## Types

Integer types: `int`, `uint`, `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`

Float types: `float`, `f32`, `f64`

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

`float` becomes `f32` or `f64` based on the compile target

## Variables

```rust
// let {name} [: {type}] = {value}
let count = 5                  // Inferred as int
let unsigned: uint = 5         // Explicit type
let converted = count.to(uint)
let text: String = count       // Converted to String automatically
let parsed = "100".to(u8)
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
s.part(start_index, length) String // Sub string using byte offsets
s.range(start_index, end_index) String // Sub string using inclusive byte offsets
let middle = s[1 .. 3] // Three bytes starting at byte offset 1
s.utf8.length // Length in Unicode characters
s.utf8.part(start_index, length) String // Sub string using character offsets
```

Full `String` API: [core](api.md#core)

## Arrays

Prefer `append` over `prepend` when possible; appending is significantly faster.

```rust
let arr = Array[int]{ 1, 2, 3 } // Create array
let arr : Array[int] = .{ 1, 2, 3 } // Using typehint
// Basics
arr.append(4)
arr.prepend(5)
let v = arr.get(0) ! panic("Empty array")
let first_three = arr[0 .. 3]
arr.clear()
//
each arr as value {}
each arr as value, index {}
```

Full `Array` API: [core](api.md#core)

Bracket ranges call an instance method marked `$range`. The hook must accept
`(start_index: uint, length: uint)` and return one value. This lets custom
collection types support the same `value[start_index .. length]` syntax.

## Maps

A `Map` is a key/value store with `String` keys and a configurable value type. Use `HashMap` when keys are not strings.

```rust
let m = Map[uint]{ "a" => 1, "b" => 2 } // Create map
let m : Map[uint] = .{ "a" => 1, "b" => 2 } // Using typehint
// Basics
m.set(key, value)
m.remove(key)
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

Use `as` to access the value in a `match` case. When every type is handled, a
`default` case is not needed. Add `null` when the value may be missing.

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
ExternError (extern) // For when an extern function returns an error
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
// ! You can also use a single line
let v = my_func() ! return
// !> pass the error to the parent caller
let v = my_func() !>
// _ Ignore the error, but the return type/value is always `void`
my_func() _
// !! panic on error
let v = my_func() !!
```

You can access all error information with the `E` identifier. `E.code` contains the error code that was thrown.

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

You can create anonymous functions by using the `fn` keyword. Based on whether you used a variable from outside the scope or not, the return type will either be a raw function pointer `fnptr()()` or a closure type `fn()()`

A `fnptr()()` type is always compatible with `fn()()`. But not the other way around. So when you need to specify a type and you want to support both raw function pointers and closures, use `fn` instead of `fnptr`.

```rust
fn main() {
    let prefix = "Hello"
    let greet = fn(name: String) {
        println(prefix + ", " + name)
    }
    greet("Sam")
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
the interface declaration.

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

- Generic type names use the same naming conventions as variable names
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

`$eq` customizes `==`. Types used as `HashMap` keys must also define `$hash`, and equal values must produce the same hash. `Array.unique()` already honours `$eq`; without `$hash`, a map would bucket by the built-in hash and break that invariant.

Generic specializations remain distinct and invariant even when their type
arguments are a compatible mode/base pair. For example, `Array[LowerCaseString]`
cannot be assigned to `Array[String]`, and `HashMap[LowerCaseString, V]` cannot
be assigned to `HashMap[String, V]`.

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

## Paths

Valk offers a `Path` mode for `String` which can be initialized by either `type hints` or using `fs.path("path")`

```rust
use valk.fs

fn main() {
    let path : fs.Path = "."
    path = path.add("folder1").add("folder2/").add("/file") // Adding parts to a path without worrying about double slashes
    println(path) // ./folder1/folder2/file
    path = path.resolve() ! panic("Failed to resolve path")
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
error when the document does not match that type.

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

```rust
use valk.time

// Init
let now = time.DateTime.new()
let datetime = time.DateTime.new(2026, 8, 8, 19, 7, 6, 123_456)
let from_str = time.DateTime.from_format("Y-m-d H:i:s.u", text) ! panic("Invalid date")

// Change
let changed = datetime.add_days(1) // Returns a new DateTime
datetime.modify_add_hours(2)       // Modifies the existing object

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

```rust
fn hi() { println("Hello") }
fn main() {
    let task = co hi()
    await task
}
```


## Access types

Declarations without a marker are available throughout their package and
private outside it. Use `-` to keep a declaration in its source file, `~` to
make it read-only outside that source, and `+` to make it public everywhere.

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

We can do atomic operations on integers by placing our operation inside an `atomic()` token.

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
```

### HTTP Server

```rust
use valk.http

fn handler(req: http.Request) http.Response {
    return http.Response.html("Hello world!")
}

fn main() {
    let host = "127.0.0.1"
    let port : u16 = 9000
    let s = http.Server.new(host, port, handler) ! {
        println("Failed to initialize http server")
        return
    }
    println("HTTP server - http://%host:%port")
    s.start()
}
```

The server accepts HTTP/1.1 origin-form requests and `OPTIONS *`. Request
methods and header names must be HTTP tokens, request targets must use valid
URI characters and percent escapes, and every request must contain exactly one
valid `Host` header.

## Sockets

API for [valk.net](api.md#net)

Create a socket server/client. Currently only supports TCP.

Example

```rust
use valk.net

// Server
fn server() {
    let sock = net.Socket.server(net.SocketType.tcp, "127.0.0.1", 8000) ! panic("Failed to open socket")
    let buffer = Slice[u8].new(1000, 0)
    while true {
        let con = sock.accept() ! {
            println("# Failed to accept connection")
            continue;
        }
        // Handle connection (normally you do this on a separate coroutine so you can keep accepting new connections)
        while true {
            let bytes = con.recv(buffer) ! {
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
    let buffer = Slice[u8].new(1000, 0)
    let bytes = con.recv(buffer) ! panic("Client failed to read from connection")
    println("# Client received: " + buffer.view(0, bytes).to_string())
    con.close() ! panic("Failed to close connection")
}
```

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

Supported utilities include bcrypt, BLAKE2b, Base64, MD5, SHA-1, SHA-256, and secure random values.

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
themselves require an unsafe scope.

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
```

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

`shared T` is a read-only view used to pass data across threads. Data-race-unsafe properties cannot be changed through that view, while integer properties use atomic access. Converting `T` to `shared T` requires its complete reachable object graph to be unique. Creating the view consumes that uniqueness and invalidates further use through prior ordinary aliases. A shared view cannot be converted back to `T`.

You can use `core.race_lock()` and `core.race_unlock()` as a global lock for data races. You are allowed to lock multiple times (e.g. in nested functions) as long as you unlock the same amount of times (it keeps a count).
