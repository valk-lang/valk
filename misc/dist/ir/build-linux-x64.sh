#!/bin/sh
set -eu
cd "$(dirname "$0")"
clang --target=x86_64-pc-linux-gnu -Wno-override-module -O3 -pie valk-linux-x64.ll libs/linux-x64/valk-stack-swap.o -o valk-linux-x64 -luring -pthread -ldl
