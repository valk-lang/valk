
VERSION=0.0.1

HDRS=$(wildcard headers/*.valk.h)
SRC=$(wildcard src/*.valk) $(wildcard src/build/*.valk) $(wildcard src/helper/*.valk)
SRC_LIB=$(wildcard lib/src/*/*.valk) $(wildcard lib/*/*.valk)
SRC_EXAMPLE=$(wildcard debug/*.valk)

FLAGS=--def "VERSION=$(VERSION)"

# Build
valk: $(SRC) $(HDRS)
	valk-legacy build . src/*.valk -o ./valk -vv $(FLAGS)
valkd: $(SRC) $(HDRS)
	gdb --args valk-legacy build . src/*.valk -o ./valk -vv $(FLAGS)
static: $(SRC) $(HDRS)
	valk-legacy build . src/*.valk -o ./valk -vv --static $(FLAGS)

# Testing
test: valk
	mkdir -p ./debug
	./valk build ./tests/*.valk . --test -o ./debug/test-all -vv
	./debug/test-all

# Testing
test-cross: valk
	mkdir -p ./debug
	./valk build ./tests/*.valk . --test -o ./debug/test-all -vv --target linux-x64
	./valk build ./tests/*.valk . --test -o ./debug/test-all -vv --target macos-x64
	./valk build ./tests/*.valk . --test -o ./debug/test-all -vv --target macos-arm64
	./valk build ./tests/*.valk . --test -o ./debug/test-all -vv --target win-x64

# CI commands
ci-linux: $(SRC) $(HDRS)
	valk-legacy build . src/*.valk -o ./valk -vvv --static $(FLAGS) \
	-L /usr/lib/gcc/x86_64-linux-gnu/14/ \
	-L /usr/lib/gcc/x86_64-linux-gnu/13/ \
	-L /usr/lib/gcc/x86_64-linux-gnu/12/ \
	-L /usr/lib/gcc/x86_64-linux-gnu/11/ \
	-L /usr/lib/x86_64-linux-gnu \
	-L /usr/lib/llvm-15/lib/

ci-macos: $(SRC) $(HDRS)
	valk-legacy build . src/*.valk -o ./valk -vvv --static $(FLAGS) \
	-L /usr/lib/ \
	-L /usr/local/lib/ \
	-L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib/ \
	-L /opt/homebrew/lib/

ci-win: $(SRC) $(HDRS)
	valk-legacy build . src/*.valk -o ./valk -vvv --static $(FLAGS) \
	-L /usr/lib/ \
	-L /usr/local/lib/ \
	-L /mingw64/opt/llvm-15/lib/

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

dist-all: win-x64 linux-x64 macos-x64 macos-arm64

# Toolchains for building distributions
toolchains:
	chmod +x ./toolchains/setup.sh
	./toolchains/setup.sh

# Misc
clean:
	rm ./valk

.PHONY: clean toolchains dist-all valkd static test linux-x64 macos-x64 macos-arm64 win-x64 ci-linux
