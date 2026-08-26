package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
)

const source = `{"name":"Alice","age":30,"email":"alice@example.com"}`

var sourceBytes = []byte(source)

func parseAmount() int {
	if len(os.Args) < 2 {
		return 2_000_000
	}
	amount, err := strconv.Atoi(os.Args[1])
	if err != nil || amount < 1 {
		panic("amount must be a positive integer")
	}
	return amount
}

func main() {
	amount := parseAmount()
	var document map[string]any
	for i := 0; i < amount; i++ {
		var decoded map[string]any
		if err := json.Unmarshal(sourceBytes, &decoded); err != nil {
			panic(err)
		}
		document = decoded
	}

	var encoded []byte
	for i := 0; i < amount; i++ {
		var err error
		encoded, err = json.Marshal(document)
		if err != nil {
			panic(err)
		}
	}

	fmt.Printf("%s|%.0f|%s\n", document["name"], document["age"], document["email"])
	fmt.Println(len(encoded))
}
