#!/bin/sh
set -eu
cd "$(dirname "$0")"
clang --target=aarch64-linux-gnu -Wno-override-module -O3 -pie valk-linux-arm64.ll libs/linux-arm64/valk-stack-swap.o -o valk-linux-arm64 -luring -pthread -ldl
