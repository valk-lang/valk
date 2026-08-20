
# Language design

## Overview

```rust
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

// Interface (tagged union)
interface Printable {
    fn print();
}

// Trait (re-usable code for classes & structs)
trait MyTrait {
    // properties & functions
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

// Value tokens
fn example() {
}
```
