# BusyBox WASM

> BusyBox 1.37.0 compiled to WebAssembly via [WASI SDK](https://github.com/WebAssembly/wasi-sdk), runnable in [wasmtime](https://wasmtime.dev/) and other WASI runtimes.

[中文文档](README_zh.md)

## What is This

This project ports [BusyBox](https://busybox.net/) — the Swiss Army Knife of Embedded Linux — to WebAssembly. It produces a single `busybox.wasm` binary containing **101 standard Unix utilities** that can run in any WASI-compliant runtime.

This is **not** an official BusyBox project. It is a fork that adds a WASI compatibility layer on top of the BusyBox 1.37.0 source tree.

For detailed command-by-command documentation including known limitations, see [COMMANDS.md](COMMANDS.md).

For documentation on the built-in shell (wsh), see [WSH.md](WSH.md).

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

### Run

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
| `wasi/wasi_tls_glue.c` | Inline TLS glue for single-process WASM: makes HTTPS work without fork/socketpair |
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
| Networking | Partially works | HTTP and HTTPS (wget), DNS (nslookup), TCP (nc/telnet) work with network flags |
| Processes | Not supported | No `fork()`, `exec()`, `waitpid()` — always returns error |
| Pipes | OS-level not available | No `pipe()`, `dup2()` — but wsh simulates pipelines via temp files |
| Signals | Not supported | Stubs return `ENOSYS`; no `kill`, `SIGINT` handling |
| Users/Groups | Not supported | `getpwuid()`, `getgrnam()` return NULL |
| Mount/filesystem | Not supported | No `mount()`, `umount()`, `statfs()` returns defaults |
| Terminals | Limited | `tcgetattr()`/`tcsetattr()` return -1 |
| Symlinks | Not supported | wasmtime prohibits symlink creation; `ln -s` returns EPERM |
| Permissions | Ignored | `chmod`, `fchmod`, `chown` are no-ops in the WASM sandbox |

Commands that **work well**: file operations (cat, cp, mv, rm, ls), text processing (grep, sed, awk, sort), compression (gzip, bzip2, xz), checksums (md5sum, sha256sum), networking (wget with HTTPS, nc), and other single-process utilities.

## License

BusyBox is licensed under the **GNU General Public License v2**. See [LICENSE](LICENSE) for details.

WASM adaptation layer files are also GPL v2, as they are derived from the BusyBox source tree.
