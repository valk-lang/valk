package main

import (
	"crypto/md5"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
)

func main() {
	fileName := "sample"
	n := 10
	if len(os.Args) > 1 {
		fileName = os.Args[1]
	}
	if len(os.Args) > 2 {
		n, _ = strconv.Atoi(os.Args[2])
	}
	jsonStr, _ := os.ReadFile(fileName + ".json")
	var data GeoData
	json.Unmarshal([]byte(jsonStr), &data)
	printHash(data.ToJsonString())
	array := make([]GeoData, 0, n)
	for i := 0; i < n; i++ {
		var data GeoData
		json.Unmarshal([]byte(jsonStr), &data)
		array = append(array, data)
	}
	printHash(ToJsonString(array))
}

func printHash(json []byte) {
	hasher := md5.New()
	hasher.Write(json)
	fmt.Printf("%x\n", hasher.Sum(nil))
}

type GeoData struct {
	Type     string    `json:"type"`
	Features []Feature `json:"features"`
}

func ToJsonString(array []GeoData) []byte {
	if bytes, err := json.Marshal(array); err == nil {
		return bytes
	}
	return []byte{}
}

func (data *GeoData) ToJsonString() []byte {
	if bytes, err := json.Marshal(data); err == nil {
		return bytes
	}
	return []byte{}
}

type Feature struct {
	Type       string     `json:"type"`
	Properties Properties `json:"properties"`
	Geometry   Geometry   `json:"geometry"`
}

type Properties struct {
	Name string `json:"name"`
}

type Geometry struct {
	Type        string        `json:"type"`
	Coordinates [][][]float64 `json:"coordinates"`
}
