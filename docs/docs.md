
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
* [Functions](#functions)
   * [Error Handling](#error-handling)
* [Structs](#structs)
* [Globals](#globals)


<br></td><td width=200px><br>


- [Tokens](#tokens)
    * [Let](#variables)
    * [If/Else](#if-else)
    * [While](#while)
    * [Each](#each)
    * [Throw](#error-handling)

<br></td><td width=200px><br>

* [Advanced](#advanced)
    * [Access Types](#access-types)
    * [Value Scopes](#value-scopes)
    * [Compile Conditions](#compile-conditions)
    * [Atomics](#atomics)
    * [Testing](#testing)

<br></td><td width=200px><br>

* [Unsafe](#unsafe)
    * WIP 🔨

<br></td></tr>
</table>

## Getting started

Install on linux, macos or WSL

```sh
curl -s https://valk-lang.dev/install.sh | bash -s latest
# files stored in: /opt/valk
# link created: /usr/local/bin/valk
```

Windows: see our [Download page](https://valk-lang.dev/download). Just unzip the files into a folder and use `valk.exe` in your terminal.


## Basic example

```rust
// main.va
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
        "my_namespace": "src/my-namespace",
        "models": "src/database/models",
        "controllers": "src/controllers"
    }
}
```

```rust
// main.va
use my_namespace

fn main() {
    // Calling a function from another namespace
    my_namespace:thumbs_up()
}
```

```rust
// src/my-namespace/demo.va
fn thumbs_up() {
    println("👍")
}
```

## Packages

Work in progress.

## Types

Types: `String` `Array` `Map`

Integer types: `i8` `i16` `i32` `i64` `int` `u8` `u16` `u32` `u64` `uint`

Float types: (WIP)

Other: `ptr` <- raw pointer (unsafe)

## Variables

```rust
// let {name} [: {type}] = {value}
let a = 5            // int (default)
let b : uint = 5     // uint
let c : u8 = "test"  // Compile error
let d = b @as u8     // Casting
```

## Definitions

### Functions

```rust
fn add(arg1: int, arg2: int (5)) int {
    return arg1 + arg2
}

fn main() {
    add(1) // result: 6
    add(2, 2) // result: 4
}
```

### Error handling

```rust
my_func() ? {alternative-value}
my_func() ! {code-that-ends-with: return, break, continue, throw}
```

```rust
fn add(value: int) int !too_big {
    if value > 100 {
        throw too_big
    }
    return value + 10
}

fn main() {
    // Alternative value in case of an error
    let x = add(10) ? 0 // result: 20
    x = add(200) ? 5 // result: 5

    // Alternative value using scope
    x = add(200) ? <{
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

### Structs

```rust
struct MyStruct {
    a: String
    b: String ("default value")
    c: uint (100)
}

fn main() {
    let obj = MyStruct {
        a: "TEST"
    }
    println(obj.a)   // output: TEST
    obj.a = "UPDATE" // Set property
    println(obj.a)   // output: UPDATE
    println(obj.b)   // output: default value
    println(obj.c)   // output: 100
}
```

### Globals

```
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

## Advanced

### Access types

With access types we control who can access what. By default your declared types, functions, properties, etc. are public, but we can use `-` (private) and `~` (readonly) to limit the access to them.

```rust
fn ... // public
- fn ...   // private, function can only be accessed from this file
-ns fn ...  // private, function can only be accessed from this namespace
-pkg fn ... // private, function can only be accessed from this package

struct MyStruct {
    {prop-name}: ... // public
    - {prop-name}: ...    // private, property can only be accessed from this file
    -ns {prop-name}:  ...  // private, property can only be accessed from this namespace
    -pkg {prop-name}: ...  // private, property can only be accessed from this package
    ~ {prop-name}: ...    // readonly, property can only be changed from this file
    ~ns {prop-name}: ...   // readonly, property can only be changed from this file
    ~pkg {prop-name}: ...  // readonly, property can only be changed from this file
}
```

For rare cases when you want to ignore access types, you can type `@ignore_access_types` at the top of file.

### Value scopes

With `value scopes` we can execute code that eventually returns a value.

```rust
let a = 5
let b = <{
    if a > 100 {
        println("Multiply by 2")
        return a * 2
    }
    println("Add 10")
    return a + 10
}
println(b)
// output:
// Add 10
// 15
```

This feature is very useful in error handling for when we want to provide an alternative value but also want to execute some code when it happens. e.g. for logging.

```rust
let a = might_error() ? <{
    Mylogger.log("might_error() returned an error, this should not happen!")
    return 0
}
```

### Compile conditions

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

### Atomics

We can do atomic operations on integers by placing our operation inside an `atomic()` token.

```rust
// {value-before-updating} = atomic( {variable} {op} {value} )
let v = 5
let a = atomic(v + 2)
println(v) // 7
println(a) // 5
```

### Testing

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

## Unsafe

Work in progress 🔨

### cstructs

cstructs are structs that are not garbage collected and cant be modified by the compiler. It mostly used for integrating c libraries, but can also be used if you just do not want garbage collection on your struct.

```rust
cstruct MyStruct {
    a: i32
    b: i32
}

fn main() {
    let ob = MyStruct{
        a: 5
        b: 100
    }
}
```

Valk allocates these cstruct objects using `valk:mem:alloc` and you can use `valk:mem:free` to free these objects. But you are free to allocate / free these objects in your own way.

```rust
let ob = my_alloc(sizeof(inline MyStruct))
```

### Headers

(WIP)
