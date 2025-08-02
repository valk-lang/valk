
# Documentation

## Table of contents

<table>
<tr><td width=200px><br>

* [Basic example](#basic-example)
* [Multiple files](#multiple-files)
* [Namespaces](#namespaces)
* [Packages](#packages)
* [Types](#types)
* [Variables](#variables)
* [Strings](#strings)
* [Arrays](#arrays)
* [Maps](#maps)
* [Functions](#functions)
   * [Error Handling](#error-handling)
   * [Closures](#closures)


<br></td><td width=200px><br>

* [Classes](#classes)
* [Modes](#modes)
* [Globals](#globals)

- [Tokens](#tokens)
    * [Let](#variables)
    * [If/Else](#if-else)
    * [While](#while)
    * [Each](#each)
    * [Throw](#error-handling)

<br></td><td width=200px><br>

* [Null checking](#null-checking)
* [Files](#files)
    - [Paths](#paths)
* [JSON](#json)
* [Coroutines](#coroutines)
* [Access Types](#access-types)
* [Value Scopes](#value-scopes)
* [Compile Conditions](#compile-conditions)
* [Atomics](#atomics)
* [Testing](#testing)
* [HTTP Client](#http-client)
* [HTTP Server](#http-server)
* [Sockets](#sockets)

<br></td><td width=200px><br>

* [Unsafe](#unsafe)
    * [Structs](#structs)
    * [Headers](#headers)

<br></td></tr>
</table>

## Getting started

Install on linux, macos or WSL

```sh
curl -s https://valk-lang.dev/install.sh | bash -s latest
```

Windows: see our [Download page](https://valk-lang.dev/download). Just unzip the files into a folder and use `valk.exe` in your terminal.


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

## Multiple files

To build multiple files into a program, you simply add them to the build command. However, we recommend to use only 1 file (e.g. main.valk) and put all other files into a namespace. (See next chapter)

```sh
valk build file-1.valk file-2.valk -o ./main
./main
```

## Namespaces

To organize your code we group files into different directories. Each namespace represents 1 directory. To create a namespace, you must define it in your config file `valk.json`. Which should be located in the root of your project.

```json
{
    "namespaces": {
        "my_namespace": "src/my-namespace"
    }
}
```

```rust
// main.valk
use my_namespace

fn main() {
    // Calling a function from another namespace
    my_namespace:thumbs_up()
}
```

```rust
// src/my-namespace/demo.valk
fn thumbs_up() {
    println("👍")
}
```

## Packages

Work in progress.

## Types

Types: `String` `Array` `Map`

Integer types: `int`, `uint`, `i8` `i16` `i32` `i64` `u8` `u16` `u32` `u64`

Float types: `float`, `f32`, `f64`

Other: `ptr` <- raw pointer (unsafe)

---

`int` becomes `i32` or `i64` based on the compile target

`uint` becomes `u32` or `u64` based on the compile target

`float` becomes `f32` or `f64` based on the compile target

## Variables

```rust
// let {name} [: {type}] = {value}
let v = 5             // Integers will be of type `int` by default if no typehint is available
let v : uint = 5      // Using type hint, now the compiler knows the integer should be a `uint` instead of `int`
let v = 5.to(uint)    // With .to() you can always convert any number value to any other number type
let v = 5.to(String)  // String is not a number type, but the compiler will try to find a converter function for these types
let v : String = 5    // The compiler will always automatically convert a value to String if needed/possible
let v : u8 = "100"    // Compile error because the types are not compatible
let v : u8 = "100".to(u8) // This works
```

## Strings

```rust
let name = "Peter"
let msg1 = "Hello " + name + "!" // Concat strings
let msg2 = "Hello %name!" // Short way
let msg3 = "Name length x 2: %{ name.length * 2 }!" // Inline value (You can use any code inside %{} as long as it can be converter to String)
let msg4 = "Hello \%name!" // Prevent inlining using '\' before '%'
let msg5 = r"Hello %name!" // Prevent inlining using 'r' (raw) at the start 
// Api
s.length // Length of string
s.starts_with(x) // Checks if string starts with ...
s.ends_with(x) // Checks if string ends with ...
s.is_empty() // Check if length == 0
s.lower() // Convert to lowercase
s.upper() // Convert to uppercase
s.is_alpha() // Check if only contains a-zA-Z
s.is_alpha_numeric() // Check if only contains a-zA-Z0-9
s.is_integer() // Check if characters are only 0-9
s.is_number() // Check if characters are only 0-9 but can contain 1 dot e.g. 123.45
s.index_of(b) ! // Returns index from a sub-string
s.index_of_byte(b) ! // Returns index from a u8/byte
s.contains(b) // Returns true if string contains sub-string
s.contains_byte(b) // Returns true if string contains a certain u8/byte
s.get(index) ! // Returns the u8/byte at index
s.part(index, amount) // Returns a sub-string
s.range(start, end) // Returns a sub-string
s.split(on) Array[String] // Split string into parts
s.trim(part) / s.rtrim(part) / s.ltrim(part)
s.replace(part, with)
s.escape() // Adds slashes in front of all special characters
s.unescape() // Removes all slashes
s.ansi.{color}() // E.g. println("hello".ansi.green()) | colors: black, red, green, yellow, blue, purple, cyan, white
```

## Arrays

```rust
// Init
let a = Array[String].new() // Init new array
let b = array[String]{ "1", "2", "3" } // Init using macro
// Api
a.length // Returns amount of items in the array
a.append(b) // Append value
a.prepend(b) // Prepend value (append is faster than prepend)
a.append_many(b) // Append multiple
a.prepend_many(b) // Prepend multiple
a.get(index) ! // Get value by index
a.set(index, value) ! // Set value by index
a.set_expand(index, value, gap_value) // Set value by index, fill the gaps with the gap-value
a.remove(index) // Remove by index
a.remove_value(value) // Remove by value
a.part(1, 3) // Copy a part from the array, args: (start-index, amount)
a.range(2, 2) // Copy a part from the array, args: (start-index, end-index, inclusive = true)
a.contains(value) // Checks if array contains a certain value
a.unique() // Make the values unique
a.unique_copy() // Returns a copy with only unique values
a.filter() // Filter out empty values
a.filter(fn() bool { ... }) // Custom filter function (return true to remove the value)
a.filter_copy(fn() bool { ... }) // Returns a copy with the filtered values
a.copy() // Copy the array
a.merge(b) // Adds values from b to a (returns a copy, use append_many if you want to modify the existing array)
a.clear() // Empties the array
```

## Maps

```rust
let a = Map[uint].new() // Init map
let b = map[uint]{ "a" => 1, "b" => 2 } // Init using macro
let c = hashmap[uint]{ "a" => 1, "b" => 2 } // Hashmap (uses more memory, but much faster look ups)
// API
m.length // Returns amount of items in the map
m.set(key, value) // Set a value
m.has(key) // Check if map has a key
m.get(key) ! // Get a value by key
m.remove(key) // Removes a value
m.keys() // Get array of all keys
m.values() // Get array of all values
m.merge(m2) // Adds values from m2 to m
m.copy() // Copy the map
m.clear()
```

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

### Error handling

```rust
// !? Provide a alternative value when an error occurs
let v = my_func() !? "hello"
// ! Run code if the function returns an error
my_func() ! { print("error") }
// ! However, if you want the return value of the function call, then the error code must and with: return, break, continue, throw, panic or an exit-function
let v = my_func() ! { print("error"); return }
// ! You can also use a single line
let v = my_func() ! return
// _ Ignore the error, but the return type is always `void`
my_func() _
```

A code example

```rust
fn add(value: int) int !too_big {
    if value > 100 : throw too_big
    return value + 10
}

fn main() {
    // Alternative value in case of an error
    let x = add(10) !? 0 // result: 20
    x = add(200) !? 5 // result: 5

    // Alternative value using scope
    x = add(200) !? <{
        println("We had an error 😢")
        return 210
    }
    // result: 210

    // Exit the function on error
    x = add(200) ! {
        println("We had an error 😢")
        return // main has a void return type, so we use an empty return
    }
    // Single line
    x = add(200) ! return
    // Break / continue loops on error
    while true {
        x = add(200) ! break // or continue
        x = add(200) ! {
            println("error, stop the loop")
            break
        }
    }
}
```

### Closures

Closures are anonymous functions

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
    u.last_name += " The Geat"
    u.print_name() // output: John Doe The Great
    User.my_static_function() // output: Hello from my static function
}
```

## Modes

With `mode` you can write a wrapper around an existing class. Allowing you to overwrite functions for custom behaviour. You cannot add new properties. Mode types are always compatible with its base type.

```rust
mode LowerCaseString for String {
    fn equals(cmp: LowerCaseString) bool $eq {
        return this.lower() == cmp.lower()
    }
}

fn main() {
    let a : String = "HELLO"
    let b : LowerCaseString = "HELLO"
    println(a == "hello") // False
    println(b == "hello") // True
}
```


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
each m as k, v {
    println(k + ":" + v)
}
// a:10 b:20 c:30
each m as v {
    println(v)
}
// 10 20 30
```

## Null-checking

When having a value with a nullable type e.g. `?String`, we often need to prove to the compiler it's not `null` before being able to use it.

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

use `valk:fs` to access all file system related functions

```rust
use valk:fs
// File & Directories
fs:read(path) // Read file, returns content as a String
fs:write(path, content, append: bool) // Write to file
fs:delete(path) // Delete file
fs:delete_recursive(path) // Delete file or directory recursive
fs:move(from_path, to_path)
fs:copy(from_path, to_path, recursive) // Copy file or directory
fs:exists(path)
fs:mkdir(path) // Create directory
fs:rmdir(path) // Delete directory
fs:is_file(path)
fs:is_dir(path)
fs:files_in(path, recursive) // Returns all files in a directory
fs:symlink(link_path, target_path) // Create a symlink
// Paths
fs:resolve(path) // Uses correct slashes + Removes double slashes + resolves `./` and `/../`
fs:realpath(path) // Returns the target path from a symlink
fs:dir_of(path) // ./part1/part2 -> ./part1
fs:basename(path) // ./part1/part2 -> part2
fs:ext(path, with_dot: bool) // Returns the extension from a path, e.g. "jpg",".jpg" otherwise ""
fs:add(part1, part2) // Returns part1 + {slash} + part2, prevents double slashes
fs:cwd() // Returns current working directory
fs:chdir(path) // Change current working directory
fs:exe_path() // Returns the path of the running executable
fs:exe_dir() // Returns the directory of the running executable
fs:home_dir() // Returns the home directory from the user running the executable
fs:path(path) // Converts String to Path class (more info below)
```

## Paths

Valk offers a `Path` mode for `String` which can be initialized by either `type hints` or using `fs:path("path")`

```rust
fn main() {
    let path : Path = "."
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

API : `valk:json`

```rust
json:decode(text) ! // Convert json string to json:Value
{json:Value}.encode(pretty) // Convert json:Value to json string
// Create values
json:null_value()
json:bool(v: bool)
json:int(v: int)
json:uint(v: uint)
json:float(v: float)
json:string(v: String)
json:array(v: Array[json:Value])
json:object(v: Map[json:Value])
// Set object keys
{json:Value}.set(key, v)
{json:Value}.remove(key)
```

With `valk:json` you can convert any type to json or json to any type out-of-the-box.

```rust
use valk:json

class A {
    msg: String ("Hello")
    b: B (B{})
}
class B {
    msg: String ("World")
}

fn main() {
    let a = A{}
    // Converting our object to json string
    let pretty = true
    let str = json:encode[A](a, pretty)
    println(str)
    // {
    //     "msg": "Hello",
    //     "b": {
    //         "msg": "World"
    //     }
    // }

    // Convert json string back to your type
    // First convert it to a json:Value
    let json_value = json:decode(str) ! panic("Invalid json syntax")
    // And now convert your json:Value to A
    let a2 = json:to_type[A](json_value)
    // Check result
    println(a2.msg + " " + a2.b.msg) // Prints: Hello world
}
```

If you need to customize how your class is converted to json or from json, then you can define the following functions to override the logic.

```rust
use valk:json

class A {
    value: int (123)
    // Object -> json:Value
    + fn to_json_value() json:Value {
        return json:int(this.value)
    }
    // json:Value -> Object
    + static fn from_json_value(jv: json:Value) SELF {
        return SELF { value: jv.int() }
    }
}
```

You can also work directly with a `json:Value` instead of converting to/from a type

```rust
use valk:json

fn main() {
    let str = "{ \"Hello\": \"world\" }"
    let v = json:decode(str) ! panic("Invalid json syntax")
    // Change some data
    v.set("Hello", json:string("Valk"))
    v.set("v1", json:bool(true))
    v.set("v2", json:null_value())
    // Encode back to json string
    let str2 = v.encode()
    print(str2) // Prints: { "Hello": "Valk", "v1": true, "v2": null }
}
```

## Coroutines

With coroutines we can run multiple functions at the same time on a single thread.

```rust
// By using `co` we are able to send both requests at the same time
// Instead of waiting for request_1 to finish before starting request_2
let request_1 = co http:request("GET", "http://some-website/api/endpoint1")
let request_2 = co http:request("GET", "http://some-website/api/endpoint2")
// Now we `await` the results
// Because `http:request` can fail we must also do some error handling
let response_1 = await request_1 !? http:Response.empty(400)
let response_2 = await request_2 !? http:Response.empty(400)
```

It can be used on any function.

```rust
fn hi() { println("Hello") } 
fn main() {
    hi() // Normal function call
    co hi() // Run function call in a coroutine
    let task = co hi() // Same
    await task // Wait until it's finished
    await co fn()() { hi() }() // Makes no sense, but you can and it works
}
```


## Access types

With access types we control who can access what. By default your declared types, functions, properties, etc. are public, but we can use `-` (private) and `~` (readonly) to limit the access to them.

```rust
fn ... // default (public within your own package, private outside the package)
+ fn ... // public everywhere
- fn ... // private everywhere

class MyClass {
    {prop-name}: ... // default
    + {prop-name}: ... // public
    - {prop-name}: ...    // private
    ~ {prop-name}: ...    // readonly
}

// Advanced
-[ns+] // Private, but public in it's own namespace
-[pkg+] // Private, but public in it's own package (The default access type)
-[pkg~ns+] // Private, readonly in own package, public in own namespace
```

For rare cases when you want to ignore access types, you can type `@ignore_access` at the top of file.

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

## Compile conditions

With `compile conditions` we can modify our code based on parameters we gave the compiler. We can also do checks on types. This can be useful when working with generic types.

```rust
fn main() {
    #if OS == linux
    println("Linux")
    #elif OS != macos
    println("Not macOS or Linux")
    #else
    println("...")
    #end

    #if @type_is_pointer(T)
    println("Type is a pointer")
    #if @type_is_gc(T)
    println("Type is a garbage collected type")
    #end
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

To test our project, we pass in the `--test` cli argument with our build command. Instead of calling our `main` function, the program will now run all your defined tests. In these tests we can use `assert` to check if something is an expected result.

```rust
test "My test" {
    let a = 10
    assert(a > 5)
    assert("this" == "that")
}
```

```sh
valk build src/*.v --test --run
```

Or we can put our tests in a different directory.

```sh
valk build src/*.v ./my-tests/*.valk --test --run
```

## HTTP Client

With `valk:http` you can send HTTP requests to APIs or download files from a url.

```rust
// Send basic request
let res = http:request("GET", "http://some-website/api/endpoint") ! panic("Request failed")

// Send GET request with data
let data = map[String]{ "key1" => "val1" }
let res = http:request("GET", "http://some-website/api/endpoint", http:Options{ query_data: data }) ! panic("Request failed")

// Send POST request with data
let json_data = map[String]{ "key1" => "val1" }.to(json:Value)
let res = http:request("POST", "http://some-website/api/endpoint", http:Options{ body: json_data.encode() }) ! panic("Request failed")

// Download file
http:download(url, to_path) ! panic("Failed to download file")
```

## HTTP Server

```js
use valk:http

fn handler(req: http:Request) http:Response {
    return http:Response.html("Hello world!")
}

fn main() {
    let host = "127.0.0.1"
    let port : u16 = 9000
    let s = http:Server.new(host, port, handler) ! {
        println("Failed to initialize http server")
        return
    }
    println("HTTP server - http://%host:%port")
    s.start()
}
```

## Sockets

Currently we only support `TCP` sockets. We are still working on expanding our `net` functionality.

```rust
use valk:net
// net:Socket
net:Socket.new_tcp(host: String, port: u16) !
// net:SocketTCP
net:SocketTCP.new(host: String, port: u16) !
// Functions for client sockets
sock.connect() net:Connection !
con.ssl_connect(host: String) ! // For SSL communication, call this once on the connection from sock.connect()
// Functions for server sockets
sock.bind() !
sock.accept() net:Connection !
// net:Connection
con.send(data: String) ! // Send bytes of a string
con.send_buffer(data: utils:ByteBuffer, skip_bytes: uint, send_all: bool) ! // Send bytes from a buffer
con.send_bytes(data: ptr, bytes: uint, send_all: bool) ! // Send bytes from a raw pointer
con.recv(buffer: utils:ByteBuffer, max_bytes: uint) uint ! // Receive data from a socket, returns amount of bytes received
con.close() // Close connection
```

Example

```rust
use valk:net
use valk:utils

// Server
fn server() {
    let sock = net:SocketTCP.new("127.0.0.1", 8000) ! panic("Failed to open socket: " + EMSG)
    sock.bind() ! panic("Failed binding to port: " + EMSG)
    let buffer = utils:ByteBuffer.new()
    while true {
        let con = sock.accept() ! {
            println("# Failed to accept connection")
            continue;
        }
        // Handle connection (normally you do this on a separate coroutine)
        while true {
            buffer.clear()
            let bytes = con.recv(buffer, 1000) ! {
                if E == E.closed : break // Connection closed
                println("# Server failed to read from connection")
                break
            }
            println("# Server received: " + buffer)
            con.send("PONG") ! {
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
    let sock = net:SocketTCP.new("127.0.0.1", 8000) ! panic("Failed to open socket: " + EMSG)
    let con = sock.connect() ! panic("Failed to connect")
    // Send
    con.send("PING") ! panic("Client failed to send data")
    // Recv
    let buffer = utils:ByteBuffer.new()
    con.recv(buffer, 1000) ! panic("Client failed to read from connection")
    println("# Client received: " + buffer)
    con.close()
}
```


## Unsafe

Although Valk aims to be a safe language, we also dont want to prevent people from doing unsafe things if they want. So what is unsafe? All tokens that start with `@` are assumed unsafe. So that and using the `ptr` type (ptr = void* in c).

We also have `struct`, which isnt unsafe, but can cause memory leaks if you forget to free the objects.

Then we have `header` files. Header files are used to make the compiler aware of functions/globals/... in 3rd party static libaries. But if you define something differently than how it exists in the library, your program will probably crash when you use it. So make sure your header definitions match the library.

## Structs

A `struct` is basically a `class` without the garbage collection. You manage the allocation/free-ing yourself. Structs are compatible with the structs from `c`. This makes them useful for integrating with c libraries.

```rust
struct MyStruct {
    a: i32
    b: i32
}

use valk:mem

fn main() {
    let ob = MyStruct{
        a: 5
        b: 100
    }
    mem:free(ob)
}
```

Behind the scenes Valk allocates struct objects using `valk:mem:alloc`. So you can free them using `valk:mem:free`. These 2 functions basically map to `malloc` & `free` from libc. So memory that comes from a c library can be freed using the `valk:mem:free` function, and the other way around.

But feel free to implement your own allocator.

```rust
fn alloc(size: uint) ptr {
    // ... code ...
}
fn make[T]() T {
    #if type_is_struct(T)
    #error "You can only allocate struct types"
    #end
    return alloc(sizeof(<T>)).@cast(T)
}
fn main() {
    let obj : MyStruct = make[MyStruct]()
}
```

## Headers

Header files are used to make the compiler aware of functions/globals/... in 3rd party static libraries. A header file should have the extension `.valk.h` and should be located in a directory that's defined in your `valk.json` under `{ "headers": { "directories": ["my-headers"] } }` -> which points to `{project-dir}/my-headers`.

A header file can also tell the compiler which library to link with, and if it should link dynamic, static or based on compiler arguments.

```rust
// {project}/my-headers/example.valk.h

#if OS == win
link "libssl"
link "libcrypto"
#else
link "ssl"
link "crypto"
#end

// Because we dont know the struct layout for this type we will just use `ptr` instead of defining a `struct`
// We can later swap this out with a `struct` if we want
alias SSL_CTX for ptr 

fn SSL_new(ctx: SSL_CTX) SSL;
fn SSL_free(ctx: SSL_CTX) void;
fn SSL_set_fd(ssl: SSL, fd: i32) void;
fn SSL_connect(ctx: SSL_CTX) i32;
```

How to use it

```rust
// main.valk
header "example" as ex

fn main() {
    let ssl = ex:SSL_new()
    ex:SSL_free(ssl)
}
```

## Linking

As mentioned above, you can tell the compiler to link with certain libraries inside a header file. But instead of that, you can also just use compiler arguments. Lets go over both methods.

In a header file:

```rust
// If add dynamic or static, it will cause the compiler to always link dynamic or static. 
// In other case it will just base itself on the compiler arguments
link [dynamic|static] "{library-name}"
// On linux/macos the linker will always look for `lib{lib-name}[.so/.a]`
// You can override this logic by defining the exact filename using `:` at the start
link ":mylib.a"
```

Using command line arguments

```bash
# This will look for libssl.so in all library directories. It will also add "/usr/my-libs" to that set of directories.
valk build src/*.valk -l ssl -L "/usr/my-libs"
# This will look for libssl.a
valk build src/*.valk -l ssl -L "/usr/my-libs" --static
```

