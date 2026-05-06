# BusyBox WASM

> 基于 [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 将 BusyBox 1.37.0 编译为 WebAssembly，可在 [wasmtime](https://wasmtime.dev/) 等 WASI 运行时中执行。

[English Documentation](README.md)

## 项目简介

本项目将 [BusyBox](https://busybox.net/) —— 嵌入式 Linux 的瑞士军刀 —— 移植到 WebAssembly 平台。产出单个 `busybox.wasm` 二进制文件，包含 **101 个标准 Unix 工具**，可在任何兼容 WASI 的运行时中运行。

这不是 BusyBox 官方项目。它是在 BusyBox 1.37.0 源码基础上添加 WASI 兼容层的分支版本。

详细的逐命令文档（包含已知限制）请参阅 [COMMANDS_zh.md](COMMANDS_zh.md)。

内置 shell (wsh) 的文档请参阅 [WSH_zh.md](WSH_zh.md)。

**亮点：**

- **Component Model**：通过 WASI Component Model 与 git（libgit2）和 python（MicroPython）组合。可在 wsh 内直接运行 `git status`、`python -c "print(42)"`。
- **引号保留**：wsh 在管道中保留带引号的参数 — `python -c "import sys; print(1)"` 作为单个参数传递，不会按空格拆分。

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

### Component 模式

将 busybox 构建为 WASI Component，可与 git 和 python 子命令组合：

```bash
# 构建 component（自动组合 git + python，如果可用）
./build_wasm.sh

# 输出：busybox.wasm（busybox + git + python）
```

组合前置条件：
- [wac](https://github.com/bytecodealliance/wac)（`cargo install wac-cli`）
- `../libgit2/build-component/git-guest.wasm`（在 libgit2 目录执行 `./build_component.sh`）
- `../micropython-1.27.0-wasi/ports/wasi/build-component/micropython-guest.wasm`（在 micropython 目录执行 `./build_component.sh`）

组件使用拆分的 WIT 接口（`agentskillmania:subcommand/git` 和 `agentskillmania:subcommand/python`），每个 guest 独立导出自己的接口。

运行组合后的 busybox：

```bash
# 通过 subcommand 调用 git
wasmtime run -W exceptions=y --dir=/tmp ./busybox.wasm wsh -c 'git status'

# 通过 subcommand 调用 python
wasmtime run -W exceptions=y -S tcp=y -S inherit-network=y --dir=/tmp \
  ./busybox.wasm wsh -c 'python print("hello")'
```

### 运行（CLI 模式）

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

## 测试

```bash
test/run_all.sh                     # 运行全部测试
test/run_all.sh cat                 # 运行指定命令的测试
test/run_all.sh --list              # 列出所有可用测试
test/run_all.sh --category core     # 运行核心工具测试
test/run_all.sh --category network  # 运行网络测试
test/run_all.sh --category integration  # 运行 Component Model 集成测试
```

测试使用 TAP 协议，按 `test/unit/`（逐命令）和 `test/integration/`（Component Model 端到端）组织。

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
| `wasi/wasi_compat.h` | 函数声明补丁，修复 WASI 头文件缺失的声明 |
| `wasi_include/` | 补充 WASI 缺失的 POSIX 定义的头文件目录 |
| `arch/wasm32/Makefile` | WASM 工具链配置 |
| `wasm-ld-wrapper.sh` | 过滤 `-nostdlib`，兼容 wasm-ld |

## 手动构建

修改构建配置可编辑 `configs/wasm_defconfig`，或运行：

```bash
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk menuconfig
```

## 限制

这是在沙箱环境中运行的 WebAssembly 移植版本，许多 POSIX 功能通过 stub 模拟：

| 类别 | 状态 | 说明 |
|------|------|------|
| 文件 I/O | 部分可用 | 需要运行时 `--dir=` 参数授权文件系统访问 |
| 网络 | 部分可用 | HTTP/HTTPS（wget）、TCP（nc/telnet）、域名解析（getaddrinfo）在带网络参数的运行时下可用；nslookup 工具本身暂不可用 |
| 进程管理 | 不可用 | 无 `fork()`、`exec()`、`waitpid()`，始终返回错误 |
| 管道 | OS 级不可用 | 无 `pipe()`、`dup2()`，但 wsh 通过临时文件模拟管道 |
| 信号 | 不可用 | stub 返回 `ENOSYS`，无 `kill`、`SIGINT` 处理 |
| 用户/组 | 不可用 | `getpwuid()`、`getgrnam()` 返回 NULL |
| 挂载/文件系统 | 不可用 | 无 `mount()`、`umount()`，`statfs()` 返回默认值 |
| 终端 | 有限 | `tcgetattr()`/`tcsetattr()` 返回 -1 |
| 符号链接 | 不可用 | wasmtime 禁止创建符号链接，`ln -s` 返回 EPERM |
| 文件权限 | 忽略 | `chmod`、`fchmod`、`chown` 在 WASM 沙箱中为空操作 |

**能正常工作的命令**：文件操作（cat、cp、mv、rm、ls）、文本处理（grep、sed、awk、sort）、压缩（gzip、bzip2、xz）、校验和（md5sum、sha256sum）、网络（wget、nc）等单进程工具。

## 文档

| 文档 | 英文 | 中文 |
|------|------|------|
| 命令参考 | [COMMANDS.md](COMMANDS.md) | [COMMANDS_zh.md](COMMANDS_zh.md) |
| Shell (wsh) | [WSH.md](WSH.md) | [WSH_zh.md](WSH_zh.md) |

## 许可证

BusyBox 采用 **GNU General Public License v2** 许可。详见 [LICENSE](LICENSE)。

WASM 适配层文件同样采用 GPL v2，因为它们派生自 BusyBox 源码。
