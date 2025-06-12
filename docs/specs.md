
# Specifications

## Error handling

The error code is stored in a variable called `E` and the message in `EMSG`. Letting the compiler decide on these variable names reduces boiler plate code.

The `_` is used to ignore an error. The compiler will say this statement returns a `void` value because the value is not garanteed.

The `!?` token is used to provide an alternative value to the function return value. Types must be compatible.

The `!` token is used to provide a piece of code that needs to be execute in case of an error. If that code exits the current scope, the return value type is that of the function call, otherwise the statement returns a `void` type.

```
test() _
test() ?! "alternative-value"
test() ! return "function-return-value"
test() ! rawstatement()
test() ! match E {
    E.fail, E.fail2 => "f1"
    E.fail3 => <{
        println(EMSG)
        return "f2"
    }
    default => {
        println("default")
    }
}

test() ! {
    println("just code")
    return "z"
}
```

## Match operator

The `match` operator runs a piece of code depending on what the value matches with. If `:` is typed after the match value, it means the match operator needs to return a value instead of just running some code.

```
// Code
match E {
	1 => print("a")
	2 => { 
        print("b")
    }
}
// Value
let x = match E : String {
	1 => "a"
	2 => "b"
}
```

## Auto converting / Casting

```
let x = 5.to(String) // lookup class function flagged with $to that returns String 
let x = 5.$to(String) // alternatively you can use `.$to` in case a `.to` function is already defined on the class
let x = 5_u32 // For numbers we can specify a number type directly
let x = 5.to(u32) // If both types are numbers and there are no matching $to functions, we cast directly
let x = x.@cast(String) // Direct casting (unsafe)
```

## Null check algo

```
1. use isset() to overwrite null types (type.nullable = false, type.null_overwrite = true)
2. if type checking .null_overwrite = true type against .nullable = false :
2.1 Loop over all sc_loop scopes between current scope and scope.not_null(decl) scope
2.1.1 Add decl & clone_chunk to loop_scope.must_not_be_null
3. When at the end of a sc_loop or a 'continue' statement, check 'loop_scope.must_not_be_null' and check if those decls are null in the current scope or not. if so, show compile error
```