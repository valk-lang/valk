
HDRS=$(wildcard headers/*.valk.h)
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)
SRC_EXAMPLE=$(wildcard debug/*.valk)

valk: $(SRC) $(HDRS)
	valkmain build . src/*.valk -o ./valk -vv
valkd: $(SRC) $(HDRS)
	gdb --args valkmain build . src/*.valk -o ./valk

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
