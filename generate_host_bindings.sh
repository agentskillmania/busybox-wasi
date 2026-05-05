#!/bin/bash
# Generate WIT host bindings for busybox-wasi component mode.
# Run this before building with COMPONENT_MODE=y.
#
# Output: component/host_runner.{h,c,o}
#
# Prerequisites: wit-bindgen 0.57+ in PATH

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIT_BINDGEN="${WIT_BINDGEN:-wit-bindgen}"
WIT_DIR="$SCRIPT_DIR/../wit"
COMPONENT_DIR="$SCRIPT_DIR/component"

if ! command -v "$WIT_BINDGEN" &>/dev/null; then
    echo "Error: wit-bindgen not found in PATH" >&2
    exit 1
fi

if [ ! -f "$WIT_DIR/subcommand.wit" ]; then
    echo "Error: WIT file not found at $WIT_DIR/subcommand.wit" >&2
    exit 1
fi

mkdir -p "$COMPONENT_DIR"

echo "Generating host bindings from $WIT_DIR/subcommand.wit"
$WIT_BINDGEN c "$WIT_DIR" --world host-runner --out-dir "$COMPONENT_DIR"

echo "Generated:"
ls -la "$COMPONENT_DIR/host_runner"*

# Compile host_runner.c into .o
WASI_SDK="${WASI_SDK:-$HOME/wasi-sdk}"
CC="$WASI_SDK/bin/wasm32-wasip2-clang"

echo "Compiling host_runner.c"
$CC -O2 -c "$COMPONENT_DIR/host_runner.c" -o "$COMPONENT_DIR/host_runner.o"

echo "Done."
