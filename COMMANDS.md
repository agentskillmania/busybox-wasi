# Command Reference

> Complete reference for all 101 commands in busybox.wasm (100 unique + 1 alias), including known limitations.

[中文文档](COMMANDS_zh.md)

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Fully functional |
| ⚠️ | Partially functional, see notes |

## Quick Summary

- **79 commands** work fully (✅)
- **22 commands** have limitations (⚠️)

---

## Archival Utilities

| Command | Status | Notes |
|---------|--------|-------|
| `gzip` | ✅ | Compress/decompress, file and pipe mode |
| `gunzip` | ✅ | Decompress gzip files |
| `bzip2` | ✅ | Compress/decompress with bzip2 |
| `bunzip2` | ✅ | Decompress bzip2 files |
| `bzcat` | ✅ | Decompress bzip2 to stdout |
| `lzop` | ✅ | Compress/decompress with lzop |
| `xz` | ⚠️ | Decompression only (`xz -d`). No compression (BusyBox config limitation) |
| `unxz` | ✅ | Decompress xz files |
| `lzma` | ⚠️ | Decompression only, same as xz |
| `unlzma` | ✅ | Decompress lzma files |
| `tar` | ⚠️ | Plain tar ✅. Compressed tar (`-z`/`-j`/`-J`) ❌ — needs fork+pipe. Workaround: `tar cf` then `gzip` separately |
| `unzip` | ✅ | List and extract zip archives. Note: `-t` (test) doesn't work, use `-l` instead |

---

## Coreutils

### File Operations

| Command | Status | Notes |
|---------|--------|-------|
| `cat` | ✅ | All flags: `-n`, `-b`, `-A`, `-s`, `-v` |
| `cp` | ✅ | `-r` works but warns about chmod ENOSYS (ignorable) |
| `mv` | ✅ | |
| `rm` | ✅ | |
| `rmdir` | ✅ | |
| `ln` | ⚠️ | Hard links ✅. `ln -s` ❌ — `Operation not permitted` |
| `link` | ✅ | Creates hard links |
| `mkdir` | ⚠️ | Single-level ✅. `mkdir -p deep/path` ❌ — tries to stat `/` |
| `install` | ⚠️ | Copies correctly but exits 1 due to chmod ENOSYS |
| `unlink` | ✅ | |
| `realpath` | ⚠️ | Works within `--dir` scope. Cannot resolve paths outside sandbox |

### File Information

| Command | Status | Notes |
|---------|--------|-------|
| `ls` | ⚠️ | Lists files ✅. `-l` shows `----------` permissions, uid/gid `0`. `-a` may error on `..` |
| `stat` | ⚠️ | File stat ✅. `-f` (filesystem stat) ❌ — statfs not available |
| `du` | ✅ | |
| `wc` | ✅ | All flags: `-l`, `-w`, `-c`, `-L` |
| `sum` | ✅ | |
| `cksum` | ✅ | |
| `crc32` | ✅ | |

### Text Processing

| Command | Status | Notes |
|---------|--------|-------|
| `echo` | ✅ | |
| `printf` | ✅ | All format specifiers |
| `head` | ✅ | All flags |
| `tail` | ✅ | Including `-f`, `-n`, `-c` |
| `grep` | ✅ | |
| `egrep` | ✅ | |
| `fgrep` | ✅ | |
| `sed` | ✅ | Including `-i` (in-place) |
| `awk` | ✅ | Full awk with GNU extensions |
| `sort` | ✅ | All flags including `-o FILE` |
| `uniq` | ✅ | |
| `cut` | ✅ | All delimiters and field selection |
| `paste` | ✅ | |
| `tr` | ✅ | Including `-d`, `-s`, `-c` |
| `tee` | ✅ | Including `-a` (append) |
| `comm` | ✅ | |
| `tac` | ✅ | |
| `nl` | ✅ | Note: `-n` numbering style not supported (BusyBox limitation) |
| `fold` | ✅ | Including `-s`, `-w` |
| `expand` | ✅ | Including `-t N` |
| `unexpand` | ✅ | |
| `shuf` | ✅ | Including `-e`, `-i`, `-n`, `-o`, `-z` |
| `split` | ✅ | Including `-l`, `-b`, `-a` |
| `od` | ✅ | Including `-x`, `-c`, `-A`, `-N` |
| `xxd` | ✅ | Including `-p`, `-r` (reverse) |
| `hd` | ✅ | |
| `hexdump` | ✅ | Including `-C` (canonical) |
| `rev` | ✅ | |
| `seq` | ✅ | Note: `-f` format string not supported (BusyBox limitation) |
| `tsort` | ✅ | |
| `strings` | ✅ | Including `-n` min length |

### Checksums and Hashes

| Command | Status | Notes |
|---------|--------|-------|
| `md5sum` | ✅ | Including `-c` (check mode) |
| `sha1sum` | ✅ | Including `-c` |
| `sha256sum` | ✅ | Including `-c` |
| `sha512sum` | ✅ | Including `-c` |
| `sha3sum` | ✅ | Including `-c` |

### Encoding

| Command | Status | Notes |
|---------|--------|-------|
| `base32` | ✅ | Encode and `-d` decode |
| `base64` | ✅ | Encode and `-d` decode |
| `uuencode` | ✅ | |
| `uudecode` | ✅ | |

### Date and Time

| Command | Status | Notes |
|---------|--------|-------|
| `date` | ⚠️ | Display ✅. `-s` (set) prints ENOSYS warning. No timezone |
| `sleep` | ✅ | Fractional seconds supported |
| `usleep` | ✅ | Microsecond sleep |

### Path Operations

| Command | Status | Notes |
|---------|--------|-------|
| `basename` | ✅ | |
| `dirname` | ✅ | |
| `pwd` | ✅ | |

### File Creation/Modification

| Command | Status | Notes |
|---------|--------|-------|
| `touch` | ✅ | Including `-t`, `-d`, `-c` |
| `truncate` | ⚠️ | Absolute sizes ✅. Relative (`+N`/`-N`) not supported (BusyBox limitation) |
| `mktemp` | ✅ | Including `-d`, `-p` |
| `dd` | ✅ | Including `if=`, `of=`, `bs=`, `count=`, `skip=`, `seek=`. Note: `conv=ucase/lcase` not supported |

### Other Coreutils

| Command | Status | Notes |
|---------|--------|-------|
| `expr` | ✅ | Arithmetic, string matching, comparison |
| `test` | ✅ | All file, string, and numeric tests |
| `true` | ✅ | |
| `false` | ✅ | |
| `yes` | ✅ | Shows benign `I/O error` when piped to `head` |

---

## Editors

| Command | Status | Notes |
|---------|--------|-------|
| `sed` | ✅ | Full sed including `-i`, `-e`, `-n`, `-f` |
| `awk` | ✅ | Full awk with GNU extensions |
| `cmp` | ✅ | Compare files byte-by-byte |
| `diff` | ✅ | Unified diff, `-r` recursive |
| `patch` | ✅ | Apply diff patches |
| `ed` | ⚠️ | Basic line editing works. No TTY features |

---

## Finding Utilities

| Command | Status | Notes |
|---------|--------|-------|
| `grep` | ✅ | All flags |
| `egrep` | ✅ | |
| `fgrep` | ✅ | |

---

## Networking Utilities

All networking commands require wasmtime network flags:

```bash
wasmtime -W exceptions=y \
  -S tcp=y -S udp=y -S inherit-network -S allow-ip-name-lookup=y \
  busybox.wasm wget http://example.com
```

| Command | Status | Notes |
|---------|--------|-------|
| `wget` | ⚠️ | Works with network flags. HTTPS supported via built-in TLS 1.2 (no certificate verification). DNS may fail without `allow-ip-name-lookup=y` |
| `nc` / `netcat` | ⚠️ | Requires network flags. Basic TCP connections work |
| `telnet` | ⚠️ | Requires network flags. Interactive TTY may be limited |
| `tcpsvd` | ⚠️ | Requires network flags |
| `udpsvd` | ⚠️ | Requires network flags |
| `ftpget` | ⚠️ | Requires network flags |
| `ftpput` | ⚠️ | Requires network flags |
| `whois` | ⚠️ | Requires network flags |
| `nslookup` | ⚠️ | DNS stubs incomplete; some query types may fail |

---

## Miscellaneous Utilities

| Command | Status | Notes |
|---------|--------|-------|
| `strings` | ✅ | Extract printable strings |
| `getopt` | ✅ | Parse command options |
| `rev` | ✅ | Reverse lines |

---

## Shell

| Command | Status | Notes |
|---------|--------|-------|
| `wsh` | ✅ | Custom WASM shell. Supports variables, command substitution, serial pipelines (via temp files). Built-ins: `echo`, `cd`, `pwd`, `exit`, `export`, `unset`. No fork/exec, no job control, no globbing |
