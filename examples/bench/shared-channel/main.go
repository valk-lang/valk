package main

import (
	"fmt"
	"os"
	"strconv"
	"sync"
)

type Message struct {
	ID     uint64
	Text   string
	Values []uint64
}

func produce(channel chan *Message, first uint64, count uint64) {
	for i := uint64(0); i < count; i++ {
		id := first + i
		values := make([]uint64, 0, 8)
		for j := uint64(0); j < 8; j++ {
			values = append(values, id+j)
		}
		channel <- &Message{ID: id, Text: strconv.FormatUint(id, 10), Values: values}
	}
	close(channel)
}

func consume(channel chan *Message) uint64 {
	total := uint64(0)
	for message := range channel {
		total += message.ID + uint64(len(message.Text))
		for _, value := range message.Values {
			total += value
		}
	}
	return total
}

func main() {
	count := uint64(1000000)
	if len(os.Args) > 1 {
		count, _ = strconv.ParseUint(os.Args[1], 10, 64)
	}

	results := make([]uint64, 4)
	var wg sync.WaitGroup
	for p := uint64(0); p < 4; p++ {
		channel := make(chan *Message, 1024)
		go produce(channel, p*count, count)
		wg.Add(1)
		go func(p uint64) {
			defer wg.Done()
			results[p] = consume(channel)
		}(p)
	}
	wg.Wait()
	total := uint64(0)
	for _, result := range results {
		total += result
	}
	fmt.Printf("messages: %d, checksum: %d\n", count*4, total)
}
