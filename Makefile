
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)

valk: $(SRC)
	valkmain build . src/*.valk -o ./valk
valkd: $(SRC)
	gdb --args valkmain build . src/*.valk -o ./valk

run: valk
	./valk build ./debug/example.valk debug -vvv

time: valk
	/usr/bin/time -v ./valk build ./debug/example.valk debug -vvv
