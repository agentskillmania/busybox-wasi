# BusyBox WASM

> 基于 [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 将 BusyBox 1.37.0 编译为 WebAssembly，可在 [wasmtime](https://wasmtime.dev/) 等 WASI 运行时中执行。

[English Documentation](README.md)

## 项目简介

本项目将 [BusyBox](https://busybox.net/) —— 嵌入式 Linux 的瑞士军刀 —— 移植到 WebAssembly 平台。产出单个 `busybox.wasm` 二进制文件，包含 **140 个标准 Unix 工具**，可在任何兼容 WASI 的运行时中运行。

这不是 BusyBox 官方项目。它是在 BusyBox 1.37.0 源码基础上添加 WASI 兼容层的分支版本。

## 快速开始

### 依赖

| 依赖 | 要求版本 | 说明 |
|------|---------|------|
| [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) | **22**（clang 22.1.0） | 必须提供 `wasm32-wasip2` 目标。更新版本不保证兼容。 |
| [wasmtime](https://wasmtime.dev/) | **43.0.0** | 需要 `-W exceptions=y` 支持 setjmp/longjmp。更新版本不保证兼容。 |
| GNU Make | 任意版本 | 构建系统 |
| 标准 Unix 工具 | 任意版本 | `bash`、`sed`、`awk` 等 |

> **注意**：本项目使用 WASI Preview 2（wasip2）和 WASM Exception Handling 提案。上方版本为测试通过的版本，其他版本或运行时不保证可用。

### 构建

**方式一：一键脚本**（配置、编译、验证全流程）

```bash
./build_wasm.sh
```

脚本会读取 `configs/wasm_defconfig` 生成配置，执行 `make clean`、编译、拷贝 `busybox.wasm`，并运行验证测试。可通过 `WASI_SDK` 和 `WASMTIME` 环境变量覆盖默认路径。

**方式二：手动构建**

```bash
make clean
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk SKIP_STRIP=y -j$(nproc)
cp busybox_unstripped busybox.wasm
```

### 运行

```bash
# 执行任意内置命令
wasmtime -W exceptions=y busybox.wasm echo "Hello, WebAssembly!"

# 列出所有可用命令
wasmtime -W exceptions=y busybox.wasm --list

# 文件操作（需要 --dir 参数授权文件系统访问）
wasmtime -W exceptions=y --dir=/tmp busybox.wasm ls /tmp

# 使用内置 shell（wsh）
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'echo hello | tr a-z A-Z'
```

## 支持的命令（140 个）

### 压缩/归档工具

`bunzip2` `bzcat` `bzip2` `cpio` `dpkg` `dpkg-deb` `gunzip` `gzip` `lzcat` `lzma` `lzop` `rpm` `rpm2cpio` `tar` `unlzma` `unxz` `unzip` `xz` `xzcat` `zcat`

### 核心工具（Coreutils）

`arch` `base32` `base64` `basename` `cat` `chroot` `chmod` `cksum` `comm` `cp` `crc32` `cut` `date` `dd` `df` `dirname` `dos2unix` `unix2dos` `du` `echo` `env` `expand` `unexpand` `expr` `factor` `false` `fold` `groups` `head` `install` `link` `ln` `ls` `md5sum` `sha1sum` `sha256sum` `sha3sum` `sha512sum` `mkdir` `mkfifo` `mktemp` `mv` `nice` `nl` `nohup` `od` `paste` `printenv` `printf` `pwd` `readlink` `realpath` `rm` `rmdir` `seq` `shred` `shuf` `sleep` `sort` `split` `stat` `sum` `sync` `fsync` `tac` `tail` `tee` `test` `timeout` `touch` `tr` `true` `truncate` `tsort` `tty` `uname` `uniq` `unlink` `usleep` `uudecode` `uuencode` `wc` `yes`

### 编辑器

`awk` `cmp` `diff` `ed` `patch` `sed` `vi`

### 查找工具

`egrep` `fgrep` `grep`

### 网络工具

`ftpget` `ftpput` `nc`（`netcat`）`nslookup` `tcpsvd` `telnet` `udpsvd` `wget` `whois`

### 系统工具

`cal` `dmesg` `getopt` `hd` `hexdump` `rev` `xxd`

### 杂项工具

`ascii` `bc` `dc` `pipe_progress` `run-parts` `strings` `which`

### Shell

`wsh` —— 专为 WASM 环境设计的轻量 shell，支持变量赋值、命令替换和串行管道执行。不支持 fork/pipe（WASM 单进程限制）。

## 架构

```
                          用户
                           |
                    wasmtime 运行时
                           |
                  +--------+--------+
                  |  busybox.wasm   |
                  +--------+--------+
                           |
              +------------+------------+
              |                         |
     wasi_main.c              WASI 兼容层
     （入口桥接）              （stub + 头文件补丁）
              |                         |
              +------------+------------+
                           |
                  BusyBox applet 调度
                           |
         +---------+-------+-------+---------+
         |         |               |         |
      coreutils  archival    networking   editors ...
```

### WASI 适配层

| 文件 | 作用 |
|------|------|
| `wasi_main.c` | 入口桥接：`__main_argc_argv` -> `busybox_real_main` |
| `wasi/wasi_stubs.c` | POSIX 函数 stub（fork、pipe、signal 等），返回 `ENOSYS` 或安全默认值 |
| `wasi_include/` | 补充 WASI 缺失的 POSIX 定义的头文件目录 |
| `arch/wasm32/Makefile` | WASM 工具链配置 |
| `wasm-ld-wrapper.sh` | 过滤 `-nostdlib`，兼容 wasm-ld |

### 工作原理

1. 使用 wasi-sdk 的 `wasm32-wasip2-clang` 编译 BusyBox 源码
2. 定义 `-D__linux__` 激活 BusyBox 的 Linux 代码路径
3. 缺失的 POSIX API 通过 stub 实现，返回 `ENOSYS`（函数未实现）
4. 所有符号在链接时完全解析
5. 产出的 WASM 二进制可在任何 WASI Preview 2 运行时中运行

## 构建系统

### 构建命令

```bash
make ARCH=wasm32 WASI_SDK=/path/to/wasi-sdk SKIP_STRIP=y -j$(nproc)
```

### 配置

构建使用 `configs/wasm_defconfig`。修改方式：

```bash
# 加载 WASM 配置
make wasm_defconfig

# 交互式菜单
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk menuconfig
```

关键配置项：
- `CONFIG_STATIC=y` — 静态链接（WASM 必须）
- `CONFIG_NOMMU=y` — 无内存管理单元
- `CONFIG_WSH=y` — 自定义 WASM shell（替代 ash/hush）

### 清理重建

```bash
make clean && make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk SKIP_STRIP=y -j$(nproc)
```

## 限制

这是在沙箱环境中运行的 WebAssembly 移植版本，许多 POSIX 功能通过 stub 模拟：

| 类别 | 状态 | 说明 |
|------|------|------|
| 文件 I/O | 部分可用 | 需要运行时 `--dir=` 参数授权文件系统访问 |
| 网络 | 部分可用 | HTTP（wget）、DNS（nslookup）、TCP（nc/telnet）在部分运行时可用 |
| 进程管理 | 不可用 | 无 `fork()`、`exec()`、`waitpid()`，始终返回错误 |
| 管道 | 不可用 | 无 `pipe()`、`dup2()`，shell 管道不可用 |
| 信号 | 不可用 | stub 返回 `ENOSYS`，无 `kill`、`SIGINT` 处理 |
| 用户/组 | 不可用 | `getpwuid()`、`getgrnam()` 返回 NULL |
| 挂载/文件系统 | 不可用 | 无 `mount()`、`umount()`，`statfs()` 返回默认值 |
| 终端 | 有限 | `tcgetattr()`/`tcsetattr()` 返回 -1，`vi` 可在基本模式下使用 |

**能正常工作的命令**：文件操作（cat、cp、mv、rm、ls）、文本处理（grep、sed、awk、sort）、压缩（gzip、bzip2、xz）、校验和（md5sum、sha256sum）等单进程工具。

**不能工作的命令**：需要进程管理的命令（ps、top、kill）、挂载操作（mount、umount）、用户管理（useradd、passwd）或进程间管道的命令。

## 开发

### 添加 POSIX Stub

编译时遇到未定义函数错误时：

1. **缺少声明**：在 `wasi_compat.h` 中添加前向声明
2. **缺少定义**：在 `wasi/wasi_stubs.c` 中添加 stub 实现
3. **缺少类型/常量**：在 `wasi_include/` 对应头文件中添加

### 修改构建配置

编辑 `configs/wasm_defconfig` 或使用 `menuconfig`。修改后需 `make clean` 再重新构建。

## 许可证

BusyBox 采用 **GNU General Public License v2** 许可。详见 [LICENSE](LICENSE)。

WASM 适配层文件同样采用 GPL v2，因为它们派生自 BusyBox 源码。
