
HDRS=$(wildcard headers/*.valk.h)
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)

valk: $(SRC) $(HDRS)
	valkmain build . src/*.valk -o ./valk -vv
valkd: $(SRC) $(HDRS)
	gdb --args valkmain build . src/*.valk -o ./valk

run: valk
	./valk build ./debug/example.valk debug -vvv

time: valk
	/usr/bin/time -v ./valk build ./debug/example.valk debug -vvv

toolchains:
	chmod +x ./toolchains/setup.sh
	./toolchains/setup.sh

.PHONY: toolchains
