
HDRS=$(wildcard headers/*.valk.h)
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)
SRC_LIB=$(wildcard lib/src/*/*.valk) $(wildcard lib/*/*.valk)
SRC_EXAMPLE=$(wildcard debug/*.valk)

# Development
valk: $(SRC) $(HDRS)
	valkmain build . src/*.valk -o ./valk -vv
valkd: $(SRC) $(HDRS)
	gdb --args valkmain build . src/*.valk -o ./valk
static: $(SRC) $(HDRS)
	valkmain build . src/*.valk -o ./valk -vv --static

# Distributions
linux-x64: $(SRC) $(HDRS)
	mkdir -p dist/linux-x64
	valkmain build . src/*.valk -o ./dist/linux-x64/valk -vv --static --target linux-x64
macos-x64: $(SRC) $(HDRS)
	mkdir -p dist/macos-x64
	valkmain build . src/*.valk -o ./dist/macos-x64/valk -vv --static --target macos-x64
macos-arm64: $(SRC) $(HDRS)
	mkdir -p dist/macos-arm64
	valkmain build . src/*.valk -o ./dist/macos-arm64/valk -vv --static --target macos-arm64
win-x64: $(SRC) $(HDRS)
	mkdir -p dist/win-x64
	valkmain build . src/*.valk -o ./dist/win-x64/valk -vv --static --target win-x64

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

ex: valk debug/example
	time -v ./debug/example
exw: valk debug/example.exe
	./debug/example.exe
exd: valk debug/example
	gdb ./debug/example
exv: valk debug/example
	valgrind --track-origins=no ./debug/example

clean:
	rm ./valk
	rm ./debug/example

# Setup
toolchains:
	chmod +x ./toolchains/setup.sh
	./toolchains/setup.sh

.PHONY: toolchains valkd run time ex
