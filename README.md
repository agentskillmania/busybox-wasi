# BusyBox WASM

> BusyBox 1.37.0 compiled to WebAssembly via [WASI SDK](https://github.com/WebAssembly/wasi-sdk), runnable in [wasmtime](https://wasmtime.dev/) and other WASI runtimes.

[中文文档](README_zh.md)

## What is This

This project ports [BusyBox](https://busybox.net/) — the Swiss Army Knife of Embedded Linux — to WebAssembly. It produces a single `busybox.wasm` binary containing **101 standard Unix utilities** plus a built-in shell (`wsh`), composable with `git` (libgit2) and `python` (MicroPython) via WASI Component Model.

This is **not** an official BusyBox project. It is a fork that adds a WASI compatibility layer on top of the BusyBox 1.37.0 source tree.

## Quick Start

### Prerequisites

| Dependency | Required Version | Notes |
|------------|-----------------|-------|
| [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) | **22** (clang 22.1.0) | Must provide `wasm32-wasip2` target |
| [wasmtime](https://wasmtime.dev/) | **43.0.0** | Requires `-W exceptions=y` for setjmp/longjmp |
| [wit-bindgen](https://github.com/bytecodealliance/wit-bindgen) | **0.57+** | Host binding generation |
| [wac](https://github.com/bytecodealliance/wac) | latest | `cargo install wac-cli` |
| GNU Make | Any | Build system |

> **Note**: Uses WASI Preview 2 (wasip2) and WASM Exception Handling. Versions listed are tested.

### Build

```bash
# One-shot build: compiles busybox host + composes with git + python
./build_wasm.sh

# Output: busybox.wasm
```

If guest components are not yet built, the script generates the host component and prints instructions:

```bash
cd ../libgit2 && ./build_component.sh
cd ../micropython-1.27.0-wasi/ports/wasi && ./build_component.sh
cd ../busybox-wasi && ./build_wasm.sh
```

Environment variables `WASI_SDK` and `WASMTIME` can override default paths.

### Run

```bash
# Run any built-in command
wasmtime -W exceptions=y ./busybox.wasm echo "Hello, WebAssembly!"

# List all available commands
wasmtime -W exceptions=y ./busybox.wasm --list

# File operations (requires --dir for filesystem access)
wasmtime -W exceptions=y --dir=/tmp ./busybox.wasm ls /tmp

# Use the built-in shell (wsh)
wasmtime -W exceptions=y --dir=/tmp ./busybox.wasm wsh -c 'echo hello | tr a-z A-Z'

# git via subcommand
wasmtime -W exceptions=y --dir=/tmp ./busybox.wasm wsh -c 'git status'

# python via subcommand
wasmtime -W exceptions=y -S tcp=y -S inherit-network=y --dir=/tmp \
  ./busybox.wasm wsh -c 'python -c "print(42)"'

# HTTPS download
wasmtime -W exceptions=y \
  -S tcp=y -S udp=y -S inherit-network -S allow-ip-name-lookup=y \
  --dir=/tmp ./busybox.wasm wget --no-check-certificate \
  https://example.com -O /tmp/index.html
```

### Testing

```bash
bash test/run-all.sh              # Run all tests
bash test/run-all.sh unit         # Unit tests only
bash test/run-all.sh integration  # Integration tests only
bash test/run-all.sh wsh          # WSH-related tests only
```

Tests use TAP protocol and are organized in `test/unit/` (per-command) and `test/integration/` (end-to-end).

## Documentation

| Document | English | Chinese |
|----------|---------|---------|
| Quick start & build | This file | [README_zh.md](README_zh.md) |
| Command reference | [COMMANDS.md](COMMANDS.md) | [COMMANDS_zh.md](COMMANDS_zh.md) |
| Shell (wsh) | [WSH.md](WSH.md) | [WSH_zh.md](WSH_zh.md) |
| Architecture & dev notes | [CLAUDE.md](CLAUDE.md) | — |

## License

BusyBox is licensed under the **GNU General Public License v2**. See [LICENSE](LICENSE) for details.

WASM adaptation layer files are also GPL v2, as they are derived from the BusyBox source tree.
