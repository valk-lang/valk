package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
)

type chunk struct {
	start  int
	values []float64
}

func evalA(i, j int) float64 {
	ij := i + j
	return float64(ij*(ij+1)/2 + i + 1)
}

func multiplyRange(input []float64, start, end int, transpose bool) chunk {
	values := make([]float64, end-start)
	for i := start; i < end; i++ {
		sum := 0.0
		for j, value := range input {
			if transpose {
				sum += value / evalA(j, i)
			} else {
				sum += value / evalA(i, j)
			}
		}
		values[i-start] = sum
	}
	return chunk{start: start, values: values}
}

func multiply(input []float64, transpose bool, workers int) []float64 {
	chunkSize := (len(input) + workers - 1) / workers
	results := make(chan chunk, workers)
	started := 0
	for worker := 0; worker < workers; worker++ {
		start := worker * chunkSize
		if start >= len(input) {
			break
		}
		end := start + chunkSize
		if end > len(input) {
			end = len(input)
		}
		started++
		go func() {
			results <- multiplyRange(input, start, end, transpose)
		}()
	}

	output := make([]float64, len(input))
	for i := 0; i < started; i++ {
		result := <-results
		copy(output[result.start:], result.values)
	}
	return output
}

func multiplyAtA(input []float64, workers int) []float64 {
	return multiply(multiply(input, false, workers), true, workers)
}

func positiveArg(index, fallback int) int {
	if len(os.Args) <= index {
		return fallback
	}
	value, err := strconv.Atoi(os.Args[index])
	if err != nil || value < 1 {
		panic("arguments must be positive integers")
	}
	return value
}

func main() {
	n := positiveArg(1, 8000)
	workers := positiveArg(2, 4)
	if workers > n {
		workers = n
	}

	u := make([]float64, n)
	for i := range u {
		u[i] = 1
	}
	var v []float64
	for i := 0; i < 10; i++ {
		v = multiplyAtA(u, workers)
		u = multiplyAtA(v, workers)
	}

	uv := 0.0
	vv := 0.0
	for i, value := range v {
		uv += u[i] * value
		vv += value * value
	}
	fmt.Printf("%.9f\n", math.Sqrt(uv/vv))
}
