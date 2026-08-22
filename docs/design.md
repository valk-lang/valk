
# Language design

## Overview

```rust
// Built-in types
// Booleans: bool
// Integer: i8 i16 i32 i64 int u8 u16 u32 u64 uint
// Float: f32 f64 float
// Arrays: Array[T] (array of T)
// Slices: Slice[T] (slice of T), String (slice of u8)
// Fixed array: fixed[T x {amount}]
// Closures: fn()()  fn({arg-types})({return-type}) [!Error]
// Coroutines: co()  co({return-type}) // Coroutines cannot return errors
//
// Nullable: ?T (value is either type of T or null)
// Borrow: &T (value cannot be assigned to anything, it's only for reading data)
// Inline: inline T (an inline type cannot be or contain a GC type, if so, compile error)
// Immutable: imut T (cannot change properties (recursively))
//
// Unsafe void pointer: @ptr (rawpointer)
// Unsafe pointer of T: @ptrof[T] (rawpointer of T), cstring (rawpointer of u8)

// ----------------

// Token 'use'
// Syntax: use {namespace/pacakge} [as {alias}] [{ id1 [as {alias}], id2 [as {alias}], ... }]
// Import {namespace or package}
use models
// Import namespace "validator" from package "mysql"
use mysql:validator
// Import alias
use mysql:validator as mval

// Functions
// Syntax: [pub/ns/local] fn {name}({argName}: {argType}, ...) [{return-type}] [!{error-type}] { ... }
// Function `main` is where your program starts (default return type i32, if other defined: compiler must error)
fn main() {
    let u = models.User {}
}

// Declare error type
// Syntax: error {name} ({code1}, {code2}, ...) [extends (Type1, Type2)] [payload { message: String [= {default-value}], ... }]
error MyError (error, notfound) payload { message: String }

// Function AST tokens
fn example() i32 !MyError {
    // Define variable: let {name} [: {type}] = {value}
    let a : i32 = 0
    // Define multiple variables: let ({name} [: {type}], ...) = {value}
    let (a, b) = test()
    // If/else-if/else
    if a == 0 { println("a is 0") }
    else if a > 0 { println("a > 0") }
    else { println("a < 0") }
    // While
    while a++ < 5 {
        println("a = %a")
    }
    // Each
    let list = Array[String]{ "a", "b", "c" } 
    each list as str, i {
        println("Index %i has value: %str")
    }
    // Return an error
    throw .missing { message: "Not found" }
    // Return a value
    return a
    // Single line scopes
    if true : println("Yes")
    else : println("No")
    while a-- > 0 : println("Looping...")
}

// Classes (structure which objects are managed by the GC)
// Syntax: [pub/ns/local] class {name} [is {interface1, ...}] { ... }
class A {
    // Properties
    // Syntax: [pub/ns/local] {name}: {type} [= {default-value}]
    prop1: i32 = 0
    prop2: i32
    // Functions
    // Syntax: [pub/ns/local] [static] fn {name}({argName}: {argType}, ...) [{return-type}] [!{error-type}] { ... }
    fn reset() {
        this.prop1 = 0
        this.prop2 = 0
    }
}

// Struct (structure which objects are manual memory managed)
// Syntax: [pub/ns/local] struct {name} [$packed] { ... }
struct B {
    // Same syntax as class
}

// Trait (re-usable code for classes & structs)
// Syntax [pub/ns/local] trait {name} { ... }
trait MyTrait {
    // properties & functions
}
// Usage:
class MyClass {
    use MyTrait
}

// Extend (extends a type with properties (if possible) and functions)
// You cannot extend fixed[T x N] or inline T (because those dont have a type api, aka. they dont have functions)
// Syntax: extend [type-identifer] { ... }
extend Array[T] {
    fn print_all() {
        println("Printing %{ this.length } items of type: %T")
        each this as item {
            println(item)
        }
    }
}

// Interface: define which functions a class must have (only for classes, not other types)
// Syntax: [pub/ns/local] interface {name} { ... }
// Using interfaces on a class add a hidden VTABLE property that refers to a table with pointers to the functions for this object
interface Printable {
    // Functions
    fn print();
    fn to_string() String;
}

// Union (tagged union)
// Syntax: [pub/ns/local] union {name} : Type1 | Type2 | ... { ... }
// Memory layout: { u8, T }
union C : String | int | bool {
    fn print() {
        match this {
            String as val => println("String value: %val")
            int as val => println("Int value: %val")
            default => println("Other value")
        }
    }
}

// Enum (default type: int)
// Syntax: [pub/ns/local] union {name} [: Type1] { {name} [= {value}], ... }
// Values are required if non-integer type
enum MyEnum {
    A // 0
    B = 2 // 2
    C // 1
    D // 3 (tries to avoid duplicate values)
    E = 2 // 2 (duplicate values allowed)
}

// Value creation
fn example() {
    // Integer
    let v = 100
    let v = 100_000 // Underscores are ignored by the lexer
    // Float
    let v = 100_000.0 // {int}.{int} = float
    let v : f32 = 100.0 // float 32 bit
    // String
    let v1 = "123"
    let v2 = "123 %v1" // 123 123
    let v3 = "123 %{v1.length + 1}" // 123 4
    let v4 = "123 " + v1.length + 2 // 123 32
    let v5 = "123 " + (v1.length + 2) // 123 5
    let v6 = v1.length + 2 + " 123" // 5 123
    // Create class object
    let a = MyClass {
        myprop: 123
    }
    // Create struct object
    let b = MyStruct {
        myprop: 123
    }
    // Create Array/Slice/Fixed
    let c = Array[String]{ "a", "b", "c" } // Dynamic array that can grow/shrink in size
    let d = Slice[String]{ "a", "b", "c" } // Static array with length stored in hidden property
    let e = fixed[String x 3]{ "a", "b", "c" } // Static array with length stored in type
    // Create object on stack using `inline` (only types that dont contain or are GC types)
    let e : &fixed[u8 x 100] = inline fixed[u8 x 100]{ 0... }
    // Maps
    let a = Map[u8]{ "a" => 10, "b" => 20 }
    // Math
    let v = v1 + v2 // Add
    let v = v1 - v2 // Subtract
    let v = v1 / v2 // Divide
    let v = v1 * v2 // Multiply
    let v = v1 % v2 // Modulo
    let v = v1 & v2 // Bitwise AND
    let v = v1 | v2 // Bitwise OR
    let v = v1 ^ v2 // Xor
    let v = v1 << v2 // Shift left
    let v = v1 >> v2 // Shift rigtht
    // Comparison
    if v1 == v2 : println("Equal")
    if v1 != v2 : println("Not equal")
    if v1 <= v2 : println("Less or equal")
    if v1 >= v2 : println("Greater or equal")
    if v1 < v2 : println("Less than")
    if v1 > v2 : println("Greater than")
    // Closures
    let message = "hello"
    let myfunc = fn(name: String) { println(message + " " + name) }
    myfunc("world")
    // Coroutine
    let plusone = fn(v: int) int { return v + 1 }
    let task : co(int) = co plusone(123)
    let result : int = await task
}

```

## Complex parsing logic

- How the parser handles `{`
-- `{` in a if/while condition is an AST body
-- `{` after an identifier or `]` is a init body
-- `{` after a `!` is a error handler AST body
-- `{` at the start of a value is an inline init body
-- otherwise build error

- How the parser handles `!`
-- `!` after a `)` or `]` on the same line is an error handler
-- otherwise it's a not-value (!{value})

- How the parser handles `[`
-- After the word `fixed` it's fixed-array-type-info `[{expr} x {expr}]`
-- Otherwise it's an offset body `[{expr}, {expr}, ...]`

- How the parser handles `?`
-- A `?` at the starts it's a nullable-type-expr
-- A trailing `?` is a this-or-that-expr `{expr} ? {expr} : {expr}`


