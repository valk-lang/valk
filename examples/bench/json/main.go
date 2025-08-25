
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

    fmt.Printf("Name: %s, Age: %d, Email: %s\n", p["name"], p["age"], p["email"])
	fmt.Printf("Decoded %d times in %d ms\n", amount, int(elapsed / time.Millisecond))

    // Encoding
    start = time.Now()
    str := ""

    for i := amount; i > 0; i-- {
        p = decode()
        s, err := json.Marshal(p)
        if err != nil {
            fmt.Errorf("failed to encode JSON: %w", err)
            break
        }
        str = string(s)
    }

    elapsed = time.Since(start)
	fmt.Printf("Json string: %s\n", str)
	fmt.Printf("Encoded %d times in %d ms\n", amount, int(elapsed / time.Millisecond))
}
