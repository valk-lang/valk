#!/bin/sh
set -eu
cd "$(dirname "$0")"
clang --target=arm64-apple-darwin -Wno-override-module -O3 -mmacosx-version-min=11.0 valk-macos-arm64.ll libs/macos-arm64/valk-stack-swap.o -o valk-macos-arm64
