# BusyBox WASM

> BusyBox 1.37.0 compiled to WebAssembly via [WASI SDK](https://github.com/WebAssembly/wasi-sdk), runnable in [wasmtime](https://wasmtime.dev/) and other WASI runtimes.

[中文文档](README_zh.md)

## What is This

This project ports [BusyBox](https://busybox.net/) — the Swiss Army Knife of Embedded Linux — to WebAssembly. It produces a single `busybox.wasm` binary containing **101 standard Unix utilities** that can run in any WASI-compliant runtime.

This is **not** an official BusyBox project. It is a fork that adds a WASI compatibility layer on top of the BusyBox 1.37.0 source tree.

For detailed command-by-command documentation including known limitations, see [COMMANDS.md](COMMANDS.md).

For documentation on the built-in shell (wsh), see [WSH.md](WSH.md).

**Highlights:**

- **Component Model**: Compose with git (libgit2) and python (MicroPython) via WASI Component Model. Run `git status`, `python "print(42)"` natively inside wsh.
- **Correct quoting**: wsh preserves quoted arguments across pipes — `python -c "import sys; print(1)"` passes as a single argument, not split on spaces.

## Quick Start

### Prerequisites

| Dependency | Required Version | Notes |
|------------|-----------------|-------|
| [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) | **22** (clang 22.1.0) | Must provide `wasm32-wasip2` target. Newer versions may not work. |
| [wasmtime](https://wasmtime.dev/) | **43.0.0** | Requires `-W exceptions=y` for setjmp/longjmp. Newer versions may not work. |
| GNU Make | Any | Build system |
| Standard Unix tools | Any | `bash`, `sed`, `awk`, etc. |

> **Note**: This project uses WASI Preview 2 (wasip2) and the WASM Exception Handling proposal. The versions above are the ones tested. Other versions or runtimes are not guaranteed to work.

### Build

**Option 1: One-click script** (configures, builds, and verifies)

```bash
./build_wasm.sh
```

The script reads `configs/wasm_defconfig`, runs `make clean`, builds, copies the binary to `busybox.wasm`, and runs verification tests. Environment variables `WASI_SDK` and `WASMTIME` can override default paths.

**Option 2: Manual build**

```bash
make clean
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk SKIP_STRIP=y -j$(nproc)
cp busybox_unstripped busybox.wasm
```

### Component Mode

Build busybox as a WASI Component that can compose with git and python subcommands:

```bash
# Build component (auto-composes with git + python if available)
./build_wasm.sh --component

# Output: composed-busybox.wasm (busybox + git + python)
```

Prerequisites for composition:
- [wac](https://github.com/bytecodealliance/wac) (`cargo install wac-cli`)
- `../libgit2/build-component/git-guest.wasm` (run `../libgit2/build_component.sh`)
- `../micropython-1.27.0-wasi/ports/wasi/build-component/micropython-guest.wasm` (run `./build_component.sh`)

The component uses split WIT interfaces (`agentskillmania:subcommand/git` and `agentskillmania:subcommand/python`) so each guest exports its own interface independently.

Run composed busybox:

```bash
# git via subcommand
wasmtime run -W exceptions=y --dir=/tmp composed-busybox.wasm wsh -c 'git status'

# python via subcommand
wasmtime run -W exceptions=y -S tcp=y -S inherit-network=y --dir=/tmp \
  composed-busybox.wasm wsh -c 'python print("hello")'
```

### Run (CLI Mode)

```bash
# Run any built-in command
wasmtime -W exceptions=y busybox.wasm echo "Hello, WebAssembly!"

# List all available commands
wasmtime -W exceptions=y busybox.wasm --list

# File operations (requires --dir for filesystem access)
wasmtime -W exceptions=y --dir=/tmp busybox.wasm ls /tmp

# Use the built-in shell (wsh)
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'echo hello | tr a-z A-Z'

# HTTPS download (wget with built-in TLS 1.2, no certificate verification)
wasmtime -W exceptions=y \
  -S tcp=y -S udp=y -S inherit-network -S allow-ip-name-lookup=y \
  --dir=/tmp busybox.wasm wget --no-check-certificate \
  https://example.com -O /tmp/index.html
```

## Testing

```bash
test/run_all.sh                     # Run all tests
test/run_all.sh cat                 # Run tests for a specific command
test/run_all.sh --list              # List all available tests
test/run_all.sh --category core     # Run core utility tests
test/run_all.sh --category network  # Run network tests
test/run_all.sh --category integration  # Run component model integration tests
```

Tests use TAP protocol and are organized in `test/unit/` (per-command) and `test/integration/` (component model end-to-end).

## Architecture

```
                          User
                           |
                    wasmtime runtime
                           |
                  +--------+--------+
                  |  busybox.wasm   |
                  +--------+--------+
                           |
              +------------+------------+
              |                         |
     wasi_main.c              WASI Compatibility Layer
     (entry bridge)           (stubs + header patches)
              |                         |
              +------------+------------+
                           |
                  BusyBox applet dispatch
                           |
         +---------+-------+-------+---------+
         |         |               |         |
      coreutils  archival    networking   editors ...
```

### WASI Adaptation Layer

The project adds a compatibility layer between BusyBox and the WASI runtime:

| File | Purpose |
|------|---------|
| `wasi_main.c` | Entry bridge: `__main_argc_argv` -> `busybox_real_main` |
| `wasi/wasi_stubs.c` | POSIX function stubs (fork, pipe, signal, etc.) returning `ENOSYS` or safe defaults; `/dev/urandom` simulation; TLS-transparent read/write interception |
| `wasi/wasi_tls_glue.c` | Inline TLS glue: makes HTTPS work in single-process WASM via `--wrap=read/write` interception |
| `wasi/wasi_compat.h` | Function declarations patching WASI header gaps |
| `wasi_include/` | Header files supplementing missing POSIX definitions |
| `arch/wasm32/Makefile` | Toolchain configuration for WASM build |
| `wasm-ld-wrapper.sh` | Filters `-nostdlib` for wasm-ld compatibility |

## Manual Build

To modify the build configuration, edit `configs/wasm_defconfig` or run:

```bash
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk menuconfig
```

## Limitations

This is a WebAssembly port running in a sandboxed environment. Many POSIX features are stubbed:

| Category | Status | Notes |
|----------|--------|-------|
| File I/O | Partially works | Requires `--dir=` flag in wasmtime for filesystem access |
| Networking | Partially works | HTTP/HTTPS (wget), TCP (nc/telnet), and DNS resolution (getaddrinfo) work with network flags. nslookup applet itself is not yet functional |
| Processes | Not supported | No `fork()`, `exec()`, `waitpid()` — always returns error |
| Pipes | OS-level not available | No `pipe()`, `dup2()` — but wsh simulates pipelines via temp files |
| Signals | Not supported | Stubs return `ENOSYS`; no `kill`, `SIGINT` handling |
| Users/Groups | Not supported | `getpwuid()`, `getgrnam()` return NULL |
| Mount/filesystem | Not supported | No `mount()`, `umount()`, `statfs()` returns defaults |
| Terminals | Limited | `tcgetattr()`/`tcsetattr()` return -1 |
| Symlinks | Not supported | wasmtime prohibits symlink creation; `ln -s` returns EPERM |
| Permissions | Ignored | `chmod`, `fchmod`, `chown` are no-ops in the WASM sandbox |

Commands that **work well**: file operations (cat, cp, mv, rm, ls), text processing (grep, sed, awk, sort), compression (gzip, bzip2, xz), checksums (md5sum, sha256sum), networking (wget with HTTPS, nc), and other single-process utilities.

## Documentation

| Document | English | Chinese |
|----------|---------|---------|
| Command reference | [COMMANDS.md](COMMANDS.md) | [COMMANDS_zh.md](COMMANDS_zh.md) |
| Shell (wsh) | [WSH.md](WSH.md) | [WSH_zh.md](WSH_zh.md) |

## License

BusyBox is licensed under the **GNU General Public License v2**. See [LICENSE](LICENSE) for details.

WASM adaptation layer files are also GPL v2, as they are derived from the BusyBox source tree.
