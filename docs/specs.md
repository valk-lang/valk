
# Specifications

## Error handling

The error code is stored in a variable called `E` and the message in `EMSG`. Letting the compiler decide on these variable names reduces boiler plate code.

The `_` is used to ignore an error. The compiler will say this statement returns a `void` value because the value is not garanteed.

After `!` you can provide an alternative value or some code. If the code exits the current scope, the final value will just use the function return type as the value return type. If the code does not exit, final value will have a `void` return type.

E.g. `let x = getstring() ! println("hello")` is not possible. But `let x = getstring() ! panic("hello")` is ok because `panic` exits the current scope.

```
test() _
test() ! "alternative-value"
test() ! return "function-return-value"
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