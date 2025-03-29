#!/usr/bin/env bash

chmod +x ./toolchains/setup-linux-x64.sh
./toolchains/setup-linux-x64.sh
chmod +x ./toolchains/setup-macos-x64.sh
./toolchains/setup-macos-x64.sh
chmod +x ./toolchains/setup-macos-arm64.sh
./toolchains/setup-macos-arm64.sh
chmod +x ./toolchains/setup-win-x64.sh
./toolchains/setup-win-x64.sh

echo "# All toolchains & libraries are ready"
