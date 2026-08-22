#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

chmod +x "$SCRIPT_DIR/setup-linux-x64.sh"
"$SCRIPT_DIR/setup-linux-x64.sh"
chmod +x "$SCRIPT_DIR/setup-macos-x64.sh"
"$SCRIPT_DIR/setup-macos-x64.sh"
chmod +x "$SCRIPT_DIR/setup-macos-arm64.sh"
"$SCRIPT_DIR/setup-macos-arm64.sh"
chmod +x "$SCRIPT_DIR/setup-win-x64.sh"
"$SCRIPT_DIR/setup-win-x64.sh"

echo "# All toolchains & libraries are ready"
