
package main

import (
    "fmt"
    "time"
    "runtime"
)

type Node struct {
    next *Node
}

func createObjects(amount int) *Node {
    prev := &Node{}
    first := prev
    for i := 0; i < amount; i++ {
		n := &Node{}
		prev.next = n
		prev = n
    }
	return first
}

func verify(n *Node) int {
    if n.next == nil {
        return 1
    }
    return verify(n.next) + 1
}

func main() {

    fmt.Printf("# Create objects\n")

    repeat := 50
    object_count := 500 * 1000
    list := createObjects(object_count)

    fmt.Printf("# Start\n")

    start := time.Now()
    for count := 0; count < repeat; count++ {
        runtime.GC()
    }

    elapsed := time.Since(start)
    fmt.Printf("# Done\n")

    fmt.Printf("> Finished %d collections in %s.\n", repeat, elapsed)
    fmt.Printf("> Collects per second: %d\n", repeat * 1000 / int(elapsed / time.Millisecond))
	if verify(list) == object_count + 1 {
    	fmt.Printf("> Verify: OK\n")
	} else {
    	fmt.Printf("> Verify: FAIL\n")
	}
}
