
package main

import (
    "encoding/json"
    "fmt"
    "time"
    "log"
)

type Person struct {
    Name    string `json:"name"`
    Age     int    `json:"age"`
    Email   string `json:"email"`
}

func decode() map[string]interface{} {

    jsonStr := `{"name":"Alice","age":30,"email":"alice@example.com"}`

    var result map[string]interface{}
    err := json.Unmarshal([]byte(jsonStr), &result)

    if err != nil {
        log.Fatalf("Error decoding JSON: %v", err)
    }
    return result
}

func main() {

    amount := 100_000
    var p map[string]interface{}

    start := time.Now()

    for i := amount; i > 0; i-- {
        p = decode()
    }

    elapsed := time.Since(start)

    // Check
    fmt.Printf("Name: %s, Age: %d, Email: %s\n", p["name"], p["age"], p["email"])
	fmt.Printf("Decoded %d times in %d ms\n", amount, int(elapsed / time.Millisecond))
}
