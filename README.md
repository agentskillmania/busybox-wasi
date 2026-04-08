# BusyBox WASM

> BusyBox 1.37.0 compiled to WebAssembly via [WASI SDK](https://github.com/WebAssembly/wasi-sdk), runnable in [wasmtime](https://wasmtime.dev/) and other WASI runtimes.

[中文文档](README_zh.md)

## What is This

This project ports [BusyBox](https://busybox.net/) — the Swiss Army Knife of Embedded Linux — to WebAssembly. It produces a single `busybox.wasm` binary containing **134 standard Unix utilities** that can run in any WASI-compliant runtime.

This is **not** an official BusyBox project. It is a fork that adds a WASI compatibility layer on top of the BusyBox 1.37.0 source tree.

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
```

## Supported Commands (134)

### Archival Utilities

| Command | Description |
|---------|-------------|
| `bunzip2` | Decompress bzip2 files |
| `bzcat` | Decompress bzip2 to stdout |
| `bzip2` | Compress files with bzip2 |
| `cpio` | Copy files to/from archives |
| `dpkg` | Debian package manager |
| `dpkg-deb` | Debian package archive tool |
| `gunzip` | Decompress gzip files |
| `gzip` | Compress files with gzip |
| `lzcat` | Decompress lzma to stdout |
| `lzma` | Compress files with lzma |
| `lzop` | Compress files with lzop |
| `rpm` | RPM package manager |
| `rpm2cpio` | Convert RPM to cpio |
| `tar` | Tape archive tool |
| `unlzma` | Decompress lzma files |
| `unxz` | Decompress xz files |
| `unzip` | Extract zip archives |
| `xz` | Compress files with xz |
| `xzcat` | Decompress xz to stdout |
| `zcat` | Decompress gzip to stdout |

### Coreutils

| Command | Description |
|---------|-------------|
| `arch` | Print machine architecture |
| `base32` | Base32 encode/decode |
| `base64` | Base64 encode/decode |
| `basename` | Strip directory and suffix |
| `cat` | Concatenate files |
| `chroot` | Change root directory |
| `chmod` | Change file permissions |
| `cksum` | CRC and byte count |
| `comm` | Compare sorted files |
| `cp` | Copy files |
| `crc32` | CRC32 checksum |
| `cut` | Remove sections of lines |
| `date` | Print/set date |
| `dd` | Convert and copy files |
| `dirname` | Strip filename |
| `dos2unix` | Convert DOS line endings |
| `unix2dos` | Convert Unix line endings |
| `du` | Disk usage |
| `echo` | Print text |
| `env` | Set environment |
| `expand` | Convert tabs to spaces |
| `unexpand` | Convert spaces to tabs |
| `expr` | Evaluate expressions |
| `factor` | Factor numbers |
| `false` | Return false |
| `fold` | Wrap lines |
| `groups` | Print group memberships |
| `head` | Output first lines |
| `install` | Copy files with attributes |
| `link` | Create hard link |
| `ln` | Create links |
| `ls` | List directory contents |
| `md5sum` | MD5 checksum |
| `sha1sum` | SHA1 checksum |
| `sha256sum` | SHA256 checksum |
| `sha3sum` | SHA3 checksum |
| `sha512sum` | SHA512 checksum |
| `mkdir` | Create directories |
| `mktemp` | Create temporary files |
| `mv` | Move/rename files |
| `nice` | Set process priority |
| `nl` | Number lines |
| `nohup` | Run immune to hangups |
| `od` | Octal dump |
| `paste` | Merge lines of files |
| `printenv` | Print environment |
| `printf` | Format and print |
| `pwd` | Print working directory |
| `realpath` | Print resolved path |
| `rm` | Remove files |
| `rmdir` | Remove directories |
| `seq` | Print number sequences |
| `shred` | Overwrite files securely |
| `shuf` | Shuffle lines |
| `sleep` | Delay |
| `sort` | Sort lines |
| `split` | Split files |
| `stat` | File status |
| `sum` | Checksum and block count |
| `sync` | Flush filesystem caches |
| `fsync` | Sync file to disk |
| `tac` | Concatenate in reverse |
| `tail` | Output last lines |
| `tee` | Read from stdin, write to stdout and files |
| `test` | File type and value tests |
| `touch` | Change file timestamps |
| `tr` | Translate characters |
| `true` | Return true |
| `truncate` | Shrink/extend files |
| `tsort` | Topological sort |
| `uname` | Print system information |
| `uniq` | Report repeated lines |
| `unlink` | Remove single file |
| `usleep` | Microsecond sleep |
| `uudecode` | Decode uuencoded data |
| `uuencode` | Encode binary data |
| `wc` | Word/line/byte count |
| `yes` | Repeatedly output a string |

### Editors

| Command | Description |
|---------|-------------|
| `awk` | Pattern scanning language |
| `cmp` | Compare files byte-by-byte |
| `diff` | Compare files line-by-line |
| `ed` | Line-oriented text editor |
| `patch` | Apply diffs |
| `sed` | Stream editor |
| `vi` | Screen-oriented text editor |

### Finding Utilities

| Command | Description |
|---------|-------------|
| `egrep` | Extended regex search |
| `fgrep` | Fixed string search |
| `grep` | Search text patterns |

### Networking Utilities

| Command | Description |
|---------|-------------|
| `ftpget` | Download via FTP |
| `ftpput` | Upload via FTP |
| `nc` / `netcat` | TCP/UDP network utility |
| `nslookup` | DNS lookup |
| `tcpsvd` | TCP service daemon |
| `telnet` | Telnet client |
| `udpsvd` | UDP service daemon |
| `wget` | Download via HTTP/HTTPS |
| `whois` | WHOIS client |

### System Utilities

| Command | Description |
|---------|-------------|
| `cal` | Display calendar |
| `dmesg` | Print kernel messages |
| `getopt` | Parse command options |
| `hd` | Hex dump (same as hexdump -C) |
| `hexdump` | Hexadecimal dump |
| `rev` | Reverse lines |
| `xxd` | Hex dump |

### Miscellaneous

| Command | Description |
|---------|-------------|
| `ascii` | Print ASCII table |
| `bc` | Arbitrary precision calculator |
| `dc` | Desk calculator |
| `pipe_progress` | Show pipe progress |
| `run-parts` | Run scripts in directory |
| `strings` | Print printable strings |
| `wsh` | WASM shell (custom) |

### Shell

| Command | Description |
|---------|-------------|
| `wsh` | Minimal shell for WASM environments |

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
| `wasi/wasi_stubs.c` | POSIX function stubs (fork, pipe, signal, etc.) returning `ENOSYS` or safe defaults |
| `wasi/wasi_compat.h` | Function declarations patching WASI header gaps |
| `wasi_include/` | Header files supplementing missing POSIX definitions |
| `arch/wasm32/Makefile` | Toolchain configuration for WASM build |
| `wasm-ld-wrapper.sh` | Filters `-nostdlib` for wasm-ld compatibility |

## Manual Build

If you don't want to use `build_wasm.sh`:

```bash
make clean
make ARCH=wasm32 WASI_SDK=/path/to/wasi-sdk SKIP_STRIP=y -j$(nproc)
cp busybox_unstripped busybox.wasm
```

To modify the build configuration, edit `configs/wasm_defconfig` or run:

```bash
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk menuconfig
```

## Limitations

This is a WebAssembly port running in a sandboxed environment. Many POSIX features are stubbed:

| Category | Status | Notes |
|----------|--------|-------|
| File I/O | Partially works | Requires `--dir=` flag in wasmtime for filesystem access |
| Networking | Partially works | HTTP (wget), DNS (nslookup), TCP (nc/telnet) work in some runtimes |
| Processes | Not supported | No `fork()`, `exec()`, `waitpid()` — always returns error |
| Pipes | Not supported | No `pipe()`, `dup2()` — pipelines in shell don't work |
| Signals | Not supported | Stubs return `ENOSYS`; no `kill`, `SIGINT` handling |
| Users/Groups | Not supported | `getpwuid()`, `getgrnam()` return NULL |
| Mount/filesystem | Not supported | No `mount()`, `umount()`, `statfs()` returns defaults |
| Terminals | Limited | `tcgetattr()`/`tcsetattr()` return -1; `vi` works in basic mode |
| Symlinks | Not supported | wasmtime prohibits symlink creation; `ln -s` returns EPERM |
| Permissions | Ignored | `chmod`, `fchmod`, `chown` are no-ops in the WASM sandbox |

Commands that **work well**: file operations (cat, cp, mv, rm, ls), text processing (grep, sed, awk, sort), compression (gzip, bzip2, xz), checksums (md5sum, sha256sum), and other single-process utilities.

### Commands Removed from Build

The following commands have been removed from the build because they require WASI-incompatible APIs that cannot be worked around:

| Command | Reason |
|---------|--------|
| `df` | Requires `/proc/mounts` and `statfs()` — WASI has no filesystem statistics |
| `mkfifo` | Requires `mknod()` — WASI has no concept of device nodes or named pipes |
| `readlink` | Depends on symlinks — wasmtime prohibits symlink creation |
| `timeout` | Requires `vfork()` — WASM is single-process |
| `tty` | WASI has no terminal device concept |
| `which` | No accessible PATH directories in WASM sandbox |

### Commands with Known Limitations

These commands are included in the build but have partial functionality:

| Command | Limitation |
|---------|------------|
| `chmod` | No-op (WASM sandbox has no permission model) |
| `env` | No environment variables in WASM; `env COMMAND` fails (no exec) |
| `gunzip` / `bunzip2` / `unlzma` / `unxz` | Work for file decompression; `zcat` with SEAMLESS_MAGIC doesn't work (needs fork+pipe) |
| `gzip` / `bzip2` / `xz` | Work for file compression |
| `ln` | Only hard links; `ln -s` returns EPERM (symlinks blocked) |
| `nohup` | No-op stub for signals; command still runs normally |
| `nice` | No-op stub; priority setting is meaningless in WASM |
| `nslookup` | DNS stubs are incomplete; may not work for all query types |
| `tar` | Non-compressed mode works; compressed mode (tar -z etc.) needs fork+pipe |
| `unzip -t` | Test mode opens `/dev/null` which doesn't exist in WASI; use `unzip -l` instead |

## License

BusyBox is licensed under the **GNU General Public License v2**. See [LICENSE](LICENSE) for details.

WASM adaptation layer files are also GPL v2, as they are derived from the BusyBox source tree.
