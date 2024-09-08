
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)

valk: $(SRC)
	valkmain build . src/*.valk -o ./valk

run: valk
	./valk build ./debug/example.valk debug -vvv