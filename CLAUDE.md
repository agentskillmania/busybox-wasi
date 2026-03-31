# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

BusyBox 1.37.0 的 WebAssembly (WASM) 移植版本。使用 wasi-sdk 将 BusyBox 编译为 `busybox.wasm`，可通过 wasmtime 等运行时执行。项目在标准 BusyBox 源码基础上添加了 WASI 适配层。

## 构建

```bash
# 完整构建（依赖 wasi-sdk 和 wasmtime）
./build_wasm.sh

# 清理后重建
make clean && ./build_wasm.sh
```

### 依赖

- **wasi-sdk**: 默认路径 `$HOME/wasi-sdk`，可通过 `WASI_SDK` 环境变量覆盖
- **wasmtime**: 默认路径 `$HOME/bin/wasmtime`，可通过 `WASMTIME` 环境变量覆盖

### 构建流程（build_wasm.sh 四步）

1. `make` 编译所有源码（链接阶段会失败，是预期行为）
2. 收集所有 `lib.a` 静态库
3. 编译 `wasi_stubs.c`（POSIX 函数 stub）
4. 用 `--allow-undefined` 链接最终 `busybox.wasm`

### 验证构建产物

```bash
wasmtime -W exceptions=y busybox.wasm echo "Hello"
wasmtime -W exceptions=y busybox.wasm --list
```

## 架构

### WASM 适配层（项目特有）

```
wasi_main.c    — 入口桥接，将 WASI 的 __main_argc_argv 连接到 busybox_real_main
wasi_stubs.c   — POSIX 函数 stub（网络/进程/信号/文件/终端等），全部返回 ENOSYS 或安全默认值
wasi_compat.h  — 函数声明补丁，修复 WASI 头文件条件性隐藏导致的隐式声明问题
wasi_include/  — 补丁头文件目录，补充 WASI 缺失的 POSIX 声明（如 mknod, exec 家族）
```

### WASI 链接依赖

链接时需要 `-lsetjmp -lwasi-emulated-signal -lwasi-emulated-mman -lwasi-emulated-process-clocks -lwasi-emulated-getpid`，并用 `--allow-undefined` 容忍未解析符号。

### BusyBox 核心架构（上游代码）

- **applets/** — 小程序注册表，`applets.src.h` 通过宏定义所有 262 个 applet 的名称、入口函数、位置
- **libbb/** — 公共工具库（~148 个源文件），所有 applet 共享的字符串/文件/内存操作等
- **coreutils/, networking/, archival/ 等** — 按功能分类的 applet 实现
- **include/** — 头文件和 Kconfig 生成的 `autoconf.h`
- **Kbuild** — 内核风格构建系统，每个子目录通过 `Kbuild` 文件声明编译目标

### 关键配置

- `.config` — 当前构建配置（Kconfig 格式），关键项：`CONFIG_STATIC=y`, `CONFIG_NOMMU=y`
- `configs/` — 预定义配置模板（Android, FreeBSD 等）

## 修改指南

### 添加新的 POSIX stub

在 `wasi_stubs.c` 中添加。遵循现有模式：返回 `ENOSYS`（设 `errno` 并返回 `-1`），或返回安全默认值。

### 修复编译时的隐式声明错误

在 `wasi_compat.h` 中添加函数前向声明。

### 修复链接时的 symbol mismatch 错误

在 `wasi_include/` 中创建或修改对应的头文件，确保声明与实际签名一致。

### 调整编译配置

```bash
make menuconfig   # 交互式配置
make defconfig    # 默认配置
```

## 测试

测试套件在 `testsuite/` 目录，使用 `testing.sh` 框架。运行 WASM 产物时需要 `wasmtime -W exceptions=y` 前缀。
