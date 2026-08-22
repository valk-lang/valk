#!/bin/sh
set -eu
cd "$(dirname "$0")"
clang --target=x86_64-apple-darwin -Wno-override-module -O3 -mmacosx-version-min=11.0 valk-macos-x64.ll libs/macos-x64/valk-stack-swap.o -o valk-macos-x64
