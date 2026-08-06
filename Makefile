
.DEFAULT_GOAL := valk
.DELETE_ON_ERROR:

VALKV := 0.2.5
VERSION := 0.2.6

SRC := $(wildcard src/*.valk src/*/*.valk)
LIB_SRC := $(wildcard lib/src/*.valk lib/src/*/*.valk lib/src/*/*/*.valk lib/src/*/*/*/*.valk)
COMPILER_DEPS := $(SRC) valk.json
DIST_DEPS := $(COMPILER_DEPS) $(LIB_SRC)

VC ?= valk
DIST_COMP ?= valk
TEST_COMPILER ?= ./valk
EXE_SUFFIX ?=

FLAGS := --def "VERSION=$(VERSION)"
DIST_FLAGS := . src/*.valk --static --release -vv
DEV_FLAGS := -L /opt/llvm15/lib
TEST_FLAGS := --test --def "DEF_TEST=TestValue" -vv
BENCH_JSON_ITERATIONS ?= 500
BENCH_JSON_MEMORY_DOCUMENTS ?= 100

# Compiler source is always built by the official compiler in $(VC), using that
# release's bundled valk:* namespaces. The in-tree lib is a distribution/test
# input for the resulting compiler, never a source dependency of ./src.
valk: $(COMPILER_DEPS)
	$(VC) build . src/*.valk -o ./valk -vv $(FLAGS) $(DEV_FLAGS)

valk2: $(COMPILER_DEPS)
	$(VC) build . src/*.valk -o ./valk2 -vvv $(FLAGS) $(DEV_FLAGS)

valk3: $(COMPILER_DEPS)
	$(VC) build . src/*.valk -o ./valk3 -vv $(FLAGS) $(DEV_FLAGS)

valkvg: $(COMPILER_DEPS)
	valgrind $(VC) build . src/*.valk -o ./valk2 -vv $(FLAGS) $(DEV_FLAGS)

valkexe: $(COMPILER_DEPS)
	$(VC) build . src/*.valk -o ./valk -vv $(FLAGS) $(DEV_FLAGS) --target win-x64 --static

doc: valk
	./valk doc lib/ -o docs/api.md --markdown --no-private

valk-profile: $(COMPILER_DEPS)
	valgrind --tool=callgrind --dump-instr=yes --simulate-cache=yes --collect-jumps=yes \
	$(VC) build . src/*.valk -o ./valk3 -vv $(FLAGS)

valkd: $(COMPILER_DEPS)
	gdb --args $(VC) build . src/*.valk -o ./valk2 -vv $(FLAGS)

static: $(COMPILER_DEPS)
	$(VC) build . src/*.valk -o ./valk -vv --static -l zstd -L /opt/homebrew/opt/ncurses/lib -L /usr/local/opt/ncurses/lib -L /opt/homebrew/opt/llvm@15/lib -L /usr/local/opt/llvm@15/lib $(FLAGS)

install: valk
	rm -rf ~/.vman/versions/${VERSION}/
	mkdir -p ~/.vman/versions/${VERSION}/
	cp ./valk ~/.vman/versions/${VERSION}/valk
	cp -r ./lib ~/.vman/versions/${VERSION}/
	rm -f ~/.vman/bin/valk
	ln -s ~/.vman/versions/${VERSION}/valk ~/.vman/bin/valk

update: valk
	sudo rm -rf /opt/valk/${VERSION}/
	sudo mkdir -p /opt/valk/${VERSION}/
	sudo cp ./valk /opt/valk/${VERSION}/valk
	sudo cp -r ./lib /opt/valk/${VERSION}/

# Testing
# `test` is the fast, compiled language/runtime suite. `test-all` also runs
# every standalone compiler/tooling test group used by CI.
test: $(TEST_COMPILER)
	mkdir -p ./debug
	$(TEST_COMPILER) build ./tests $(TEST_FLAGS) $(FLAGS) -o ./debug/test-core$(EXE_SUFFIX)
	./debug/test-core$(EXE_SUFFIX)

test-compile-errors: $(TEST_COMPILER)
	@VALK=$(TEST_COMPILER) ./tests/compile-errors/run.sh

test-diagnostics: $(TEST_COMPILER)
	@VALK=$(TEST_COMPILER) ./tests/diagnostics/run.sh

test-exit-code: $(TEST_COMPILER)
	@VALK=$(TEST_COMPILER) ./tests/exit-code/run.sh

test-lsp: $(TEST_COMPILER)
	@VALK=$(TEST_COMPILER) ./tests/lsp/run.sh

test-fmt: $(TEST_COMPILER)
	@VALK=$(TEST_COMPILER) ./tests/fmt/run.sh

test-codegen: $(TEST_COMPILER)
	@VALK=$(TEST_COMPILER) ./tests/codegen/run.sh

test-deps: $(TEST_COMPILER)
	@VALK=$(TEST_COMPILER) ./tests/deps/run.sh

test-all: test test-compile-errors test-diagnostics test-exit-code test-lsp test-fmt test-codegen test-deps

# Build once, then measure the union representation in fresh processes so
# allocator pools and GC high-water state do not cross benchmark modes.
bench-json: valk
	mkdir -p ./debug
	./valk build ./examples/bench/json/main.valk --release -o ./debug/bench-json
	./debug/bench-json time $(BENCH_JSON_ITERATIONS)
	./debug/bench-json memory $(BENCH_JSON_MEMORY_DOCUMENTS)

test-gc-debug: valk
	mkdir -p ./debug
	./valk build ./tests $(TEST_FLAGS) $(FLAGS) -o ./debug/test-gc-debug --def "GC_DEBUG=1"
	./debug/test-gc-debug

test-gc-shared-stress: valk
	mkdir -p ./debug
	./valk build ./tests/src/gc-shared.valk $(TEST_FLAGS) $(FLAGS) -o ./debug/test-gc-shared-stress --def "GC_DEBUG=1"
	@run=0; while [ $$run -lt 10 ]; do \
		run=$$((run + 1)); \
		echo "Shared GC stress run $$run/10"; \
		./debug/test-gc-shared-stress || exit $$?; \
	done

watchtest: valk2
	./valk2 build ./tests $(TEST_FLAGS) $(FLAGS) -o ./debug/test-all --def "GC_DEBUG=1" -w -v

test-win: valk
	mkdir -p ./debug
	./valk build ./tests $(TEST_FLAGS) -vv -o ./debug/test-win.exe --target win-x64 $(FLAGS) --def "GC_DEBUG=1" --debug
	./debug/test-win.exe

test-macos-build: valk
	mkdir -p ./debug
	./valk build ./tests $(TEST_FLAGS) -vv $(FLAGS) -o ./debug/test-macos-x64 --target macos-x64
	./valk build ./tests $(TEST_FLAGS) -vv $(FLAGS) -o ./debug/test-macos-arm64 --target macos-arm64

test-win-build: valk
	mkdir -p ./debug
	./valk build ./tests $(TEST_FLAGS) $(FLAGS) -o ./debug/test-win-x64.exe --target win-x64

test-cross-ir: valk
	mkdir -p ./debug
	./valk build ./tests $(TEST_FLAGS) $(FLAGS) -o ./debug/test-macos-x64-ir --target macos-x64 --ir --clean
	./valk build ./tests $(TEST_FLAGS) $(FLAGS) -o ./debug/test-macos-arm64-ir --target macos-arm64 --ir --clean
	./valk build ./tests $(TEST_FLAGS) $(FLAGS) -o ./debug/test-win-x64-ir --target win-x64 --ir --clean

test-cross: valk
	mkdir -p ./debug
	./valk build ./tests $(TEST_FLAGS) -o ./debug/test-linux-x64 -vv $(FLAGS) --target linux-x64
	./valk build ./tests $(TEST_FLAGS) -o ./debug/test-macos-x64 -vv $(FLAGS) --target macos-x64
	./valk build ./tests $(TEST_FLAGS) -o ./debug/test-macos-arm64 -vv $(FLAGS) --target macos-arm64
	./valk build ./tests $(TEST_FLAGS) -o ./debug/test-win-x64.exe -vv $(FLAGS) --target win-x64

# CI commands
# For linux we have to add `/usr/lib/gcc/...` because that's where stdc++ is located 
ci-linux: $(COMPILER_DEPS)
	valk -h || true
	$(VC) build . src/*.valk -o ./valk -vv --static $(FLAGS) \
	-L /usr/lib/gcc/x86_64-linux-gnu/14/ \
	-L /usr/lib/gcc/x86_64-linux-gnu/13/ \
	-L /usr/lib/gcc/x86_64-linux-gnu/12/ \
	-L /usr/lib/gcc/x86_64-linux-gnu/11/ \
	-L /usr/lib/llvm-15/lib/

ci-macos: $(COMPILER_DEPS)
	valk -h || true
	$(VC) build . src/*.valk -o ./valk -vv --static -l zstd $(FLAGS) \
	--sysroot "$$(xcrun --sdk macosx --show-sdk-path)" \
	-L /usr/local/Cellar/ncurses/6.5/lib

ci-win: $(COMPILER_DEPS)
	ls -l "./llvm/lib/"
	~/valk-dev/valk.exe -h || echo ""
	$$HOME/valk-dev/valk.exe build . src/*.valk -o ./valk -vv -c --static $(FLAGS) \
	-L "./llvm/lib/"

# Distributions
linux-x64: $(DIST_DEPS)
	vman use $(VALKV)
	rm -rf dist/linux-x64/*
	mkdir -p dist/linux-x64
	$(DIST_COMP) build -o ./dist/linux-x64/valk --target linux-x64 $(FLAGS) $(DIST_FLAGS) \
	-L "toolchains/toolchains/linux-amd64/usr/lib/gcc/x86_64-linux-gnu/12/" \
	-L "toolchains/toolchains/linux-amd64/usr/lib/x86_64-linux-gnu" \
	-L "toolchains/toolchains/linux-amd64/lib64" \
	-L "toolchains/libraries/linux-llvm-15-x64/lib" \
	--sysroot toolchains/toolchains/linux-amd64 -l pthread -l dl
	cp -r ./lib ./dist/linux-x64/
	cd ./dist/linux-x64/ && rm -f ../valk-$(VERSION)-linux-x64.tar.gz
	cd ./dist/linux-x64/ && tar -czf  ../valk-$(VERSION)-linux-x64.tar.gz valk lib
macos-x64: $(DIST_DEPS)
	vman use $(VALKV)
	rm -rf dist/macos-x64/*
	mkdir -p dist/macos-x64
	$(DIST_COMP) build -o ./dist/macos-x64/valk --target macos-x64 $(FLAGS) $(DIST_FLAGS) \
	--sysroot toolchains/toolchains/macos-11-3 \
	-L toolchains/libraries/macos-llvm-15-x64/lib
	cp -r ./lib ./dist/macos-x64/
	cd ./dist/macos-x64/ && rm -f ../valk-$(VERSION)-macos-x64.tar.gz
	cd ./dist/macos-x64/ && tar -czf  ../valk-$(VERSION)-macos-x64.tar.gz valk lib
macos-arm64: $(DIST_DEPS)
	vman use $(VALKV)
	rm -rf dist/macos-arm64/*
	mkdir -p dist/macos-arm64
	$(DIST_COMP) build -o ./dist/macos-arm64/valk --target macos-arm64 $(FLAGS) $(DIST_FLAGS) \
	--sysroot toolchains/toolchains/macos-11-3 \
	-L toolchains/libraries/macos-llvm-15-arm64/lib
	cp -r ./lib ./dist/macos-arm64/
	cd ./dist/macos-arm64/ && rm -f ../valk-$(VERSION)-macos-arm64.tar.gz
	cd ./dist/macos-arm64/ && tar -czf  ../valk-$(VERSION)-macos-arm64.tar.gz valk lib
win-x64: $(DIST_DEPS)
	vman use $(VALKV)
	rm -rf dist/win-x64/*
	mkdir -p dist/win-x64
	$(DIST_COMP) build -o ./dist/win-x64/valk --target win-x64 $(FLAGS) $(DIST_FLAGS) \
	--sysroot toolchains/toolchains/win-sdk-x64 \
	-L toolchains/toolchains/win-sdk-x64/Lib/10.0.22621.0/um/x64 \
	-L toolchains/toolchains/win-sdk-x64/MSVC/14.36.32532/lib/x64 \
	-L toolchains/libraries/win-llvm-15-x64/lib
	cp -r ./lib ./dist/win-x64/
	cp ./toolchains/libraries/win-llvm-15-x64/lld.exe ./dist/win-x64/lld-link.exe
	cp ./toolchains/libraries/win-llvm-15-x64/LLVM-C.dll ./dist/win-x64/
	cd ./dist/win-x64/ && rm -f  ../valk-$(VERSION)-win-x64.zip
	cd ./dist/win-x64/ && zip -r ../valk-$(VERSION)-win-x64.zip valk.exe lib lld-link.exe LLVM-C.dll

dist-all: win-x64 linux-x64 macos-x64 macos-arm64

# Toolchains for building distributions
toolchains:
	chmod +x ./toolchains/setup.sh
	./toolchains/setup.sh

asm:
	clang-15 -c ./misc/asm/coro/x64.s --target=x86_64-pc-linux-gnu -o ./lib/libs/linux-x64/valk-stack-swap.o
	clang-15 -c ./misc/asm/coro/x64.s --target=x86_64-apple-darwin -o ./lib/libs/macos-x64/valk-stack-swap.o
	clang-15 -c ./misc/asm/coro/x64-win.s --target=x86_64-pc-windows-msvc -o ./lib/libs/win-x64/valk-stack-swap.o
	clang-15 -c ./misc/asm/coro/arm64.s --target=arm64-apple-darwin -o ./lib/libs/macos-arm64/valk-stack-swap.o

# Misc
clean:
	rm -f ./valk
	rm -f ./valk2
	rm -f ./valk3
# rm -rf ~/.valk/cache

.PHONY: \
	asm ci-linux ci-macos ci-win clean dist-all doc install \
	linux-x64 macos-arm64 macos-x64 static toolchains update valkd valkexe \
	valk-profile valkvg watchtest win-x64 \
	test test-all test-compile-errors test-cross test-cross-ir test-diagnostics \
	test-exit-code test-fmt test-gc-debug test-gc-shared-stress test-lsp \
	test-macos-build test-win test-win-build
