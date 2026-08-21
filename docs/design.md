
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
//
// Nullable: ?T (value is either type of T or null)
// Borrow: &T (value cannot be assigned to anything, it's only for reading data)
// Inline: inline T (inlines the type)
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
fn main() {}

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

// Classes (structure which objects are managed by GC)
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
interface Printable {
    // Functions
    fn print();
    fn to_string() String;
}

// Union (tagged union)
// Syntax: [pub/ns/local] union {name} : Type1 | Type2 | ... { ... }
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

// Value tokens
fn example() {
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
    // Create object on stack
    let c : &MyStruct = inline MyStruct{ myprop: 123 }
    let d : &Slice[u8] = inline Slice[u8]{ 1, 2, 3 }
    let e : &fixed[u8 x 100] = inline fixed[u8 x 100]{ 0... }
    // Maps
    let a = Map[u8]{ "a" => 10, "b" => 20 }
}

// Built-in values
fn example() {
}
```

## Compiler language rules
