package main

import (
	"fmt"
	"os"
	"strconv"
	"sync"
)

type Message struct {
	ID       uint64
	Room     uint64
	Body     string
	Mentions []uint64
}

func render(message *Message) uint64 {
	sum := message.ID + message.Room
	for i := 0; i < len(message.Body); i++ {
		sum += uint64(message.Body[i])
	}
	for _, user := range message.Mentions {
		sum += user
	}
	return sum
}

func subscriber(inbox chan *Message) uint64 {
	total := uint64(0)
	for message := range inbox {
		total += render(message)
	}
	return total
}

func main() {
	count := uint64(500000)
	if len(os.Args) > 1 {
		count, _ = strconv.ParseUint(os.Args[1], 10, 64)
	}

	text := "The quick brown fox jumps over the lazy dog. "
	inboxes := make([]chan *Message, 0, 4)
	results := make([]uint64, 4)
	var wg sync.WaitGroup
	for s := 0; s < 4; s++ {
		inbox := make(chan *Message, 1024)
		inboxes = append(inboxes, inbox)
		wg.Add(1)
		go func(s int) {
			defer wg.Done()
			results[s] = subscriber(inbox)
		}(s)
	}

	for i := uint64(0); i < count; i++ {
		body := text + text + text + "message " + strconv.FormatUint(i, 10)
		mentions := []uint64{i % 100, i % 1000}
		message := &Message{ID: i, Room: i % 10, Body: body, Mentions: mentions}
		for _, inbox := range inboxes {
			inbox <- message
		}
	}
	for _, inbox := range inboxes {
		close(inbox)
	}
	wg.Wait()

	total := uint64(0)
	for _, result := range results {
		total += result
	}
	fmt.Printf("messages: %d, subscribers: 4, checksum: %d\n", count, total)
}
