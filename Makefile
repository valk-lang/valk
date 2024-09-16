
HDRS=$(wildcard headers/*.valk.h)
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)
SRC_EXAMPLE=$(wildcard debug/*.valk)

valk: $(SRC) $(HDRS)
	valkmain build . src/*.valk -o ./valk -vv
valkd: $(SRC) $(HDRS)
	gdb --args valkmain build . src/*.valk -o ./valk
static: $(SRC) $(HDRS)
	valkmain build . src/*.valk -o ./valk -vv --static

# ///
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
# ///

run: valk
	./valk build ./debug/example.valk debug -v -o ./debug/test

time: valk
	/usr/bin/time -v ./valk build ./debug/example.valk debug -v -o ./debug/test

debug/example: $(SRC_EXAMPLE)
	./valk build ./debug/example.valk debug -v -o ./debug/example

ex: valk debug/example
	./debug/example

toolchains:
	chmod +x ./toolchains/setup.sh
	./toolchains/setup.sh

.PHONY: toolchains valkd run time ex
