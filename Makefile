
VERSION=0.0.1

HDRS=$(wildcard headers/*.valk.h)
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)
SRC_LIB=$(wildcard lib/src/*/*.valk) $(wildcard lib/*/*.valk)
SRC_EXAMPLE=$(wildcard debug/*.valk)

FLAGS=--def "VERSION=$(VERSION)"

# Development
valk: $(SRC) $(HDRS)
	valk-legacy build . src/*.valk -o ./valk -vv $(FLAGS)
valkd: $(SRC) $(HDRS)
	gdb --args valk-legacy build . src/*.valk -o ./valk $(FLAGS)
static: $(SRC) $(HDRS)
	valk-legacy build . src/*.valk -o ./valk -vv --static $(FLAGS)

# Distributions
linux-x64: $(SRC) $(HDRS)
	rm -rf dist/linux-x64/*
	mkdir -p dist/linux-x64
	valk-legacy build . src/*.valk -o ./dist/linux-x64/valk -vv --static --target linux-x64 --clean $(FLAGS)
	cp -r ./lib ./dist/linux-x64/
	cd ./dist/linux-x64/ && rm -f ../valk-$(VERSION)-linux-x64.tar.gz
	cd ./dist/linux-x64/ && tar -czf  ../valk-$(VERSION)-linux-x64.tar.gz valk lib
macos-x64: $(SRC) $(HDRS)
	rm -rf dist/macos-x64/*
	mkdir -p dist/macos-x64
	valk-legacy build . src/*.valk -o ./dist/macos-x64/valk -vv --static --target macos-x64 --clean $(FLAGS)
	cp -r ./lib ./dist/macos-x64/
	cd ./dist/macos-x64/ && rm -f ../valk-$(VERSION)-macos-x64.tar.gz
	cd ./dist/macos-x64/ && tar -czf  ../valk-$(VERSION)-macos-x64.tar.gz valk lib
macos-arm64: $(SRC) $(HDRS)
	rm -rf dist/macos-arm64/*
	mkdir -p dist/macos-arm64
	valk-legacy build . src/*.valk -o ./dist/macos-arm64/valk -vv --static --target macos-arm64 --clean $(FLAGS)
	cp -r ./lib ./dist/macos-arm64/
	cd ./dist/macos-arm64/ && rm -f ../valk-$(VERSION)-macos-arm64.tar.gz
	cd ./dist/macos-arm64/ && tar -czf  ../valk-$(VERSION)-macos-arm64.tar.gz valk lib
win-x64:
	rm -rf dist/win-x64/*
	mkdir -p dist/win-x64
	valk-legacy build . src/*.valk -o ./dist/win-x64/valk -vv --static --target win-x64 --clean $(FLAGS)
	cp -r ./lib ./dist/win-x64/
	cp -r ./toolchains/libraries/win-llvm-15-x64/lld.exe ./dist/win-x64/lld-link.exe
	cd ./dist/win-x64/ && rm -f  ../valk-$(VERSION)-win-x64.zip
	cd ./dist/win-x64/ && zip -r ../valk-$(VERSION)-win-x64.zip valk.exe lib lld-link.exe

test: valk
	./valk build ./tests/*.valk . --test -o ./debug/test-all -vv
	./debug/test-all

# Testing
run: valk
	./valk build ./debug/example.valk debug -v -o ./debug/example
rund: valk
	gdb --args ./valk build ./debug/example.valk debug -v -o ./debug/example

time: valk
	/usr/bin/time -v ./valk build ./debug/example.valk debug -v -o ./debug/example

debug/example: valk $(SRC_EXAMPLE) $(SRC_LIB)
	./valk build ./debug/example.valk debug -vv -o ./debug/example
debug/example.exe: valk $(SRC_EXAMPLE) $(SRC_LIB)
	./valk build ./debug/example.valk debug -vv -o ./debug/example.exe --target win-x64
debug/test: valk $(SRC_EXAMPLE) $(SRC_LIB)
	./valk build ./debug/example.valk debug -vv -o ./debug/test --test

ex: valk debug/example
	time -v ./debug/example
ext: valk debug/test
	time -v ./debug/test
exw: valk debug/example.exe
	./debug/example.exe
exd: valk debug/example
	gdb ./debug/example
exv: valk debug/example
	valgrind --track-origins=no ./debug/example

clean:
	rm ./valk
	rm ./debug/example

dist_setup:
	chmod +x ./toolchains/setup.sh
	./toolchains/setup.sh

dist_all: win-x64 linux-x64 macos-x64 macos-arm64

.PHONY: dist_setup valkd run time ex
