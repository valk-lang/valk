package main

import (
	"fmt"
	"os"
	"strconv"
)

type node struct {
	left  *node
	right *node
}

type treeResult struct {
	index      int
	iterations int
	depth      int
	check      int
}

func makeTree(depth int) *node {
	if depth == 0 {
		return &node{}
	}
	return &node{left: makeTree(depth - 1), right: makeTree(depth - 1)}
}

func (tree *node) check() int {
	if tree.left == nil {
		return 1
	}
	return 1 + tree.left.check() + tree.right.check()
}

func checkDepth(index, depth, iterations int, results chan<- treeResult) {
	check := 0
	for i := 0; i < iterations; i++ {
		check += makeTree(depth).check()
	}
	results <- treeResult{index: index, iterations: iterations, depth: depth, check: check}
}

const minDepth = 4

func main() {
	maxDepth := 5
	if len(os.Args) > 1 {
		value, err := strconv.Atoi(os.Args[1])
		if err != nil {
			panic("invalid maximum depth")
		}
		maxDepth = value
	}
	if minDepth+2 > maxDepth {
		maxDepth = minDepth + 2
	}

	stretchDepth := maxDepth + 1
	stretchCheck := makeTree(stretchDepth).check()
	fmt.Printf("stretch tree of depth %d\t check: %d\n", stretchDepth, stretchCheck)

	longLived := makeTree(maxDepth)
	resultCount := (maxDepth-minDepth)/2 + 1
	completed := make(chan treeResult, resultCount)
	results := make([]treeResult, resultCount)

	index := 0
	for depth := minDepth; depth <= maxDepth; depth += 2 {
		iterations := 1 << uint(maxDepth-depth+minDepth)
		go checkDepth(index, depth, iterations, completed)
		index++
	}

	for i := 0; i < resultCount; i++ {
		result := <-completed
		results[result.index] = result
	}
	for _, result := range results {
		fmt.Printf("%d\t trees of depth %d\t check: %d\n", result.iterations, result.depth, result.check)
	}

	fmt.Printf("long lived tree of depth %d\t check: %d\n", maxDepth, longLived.check())
}
