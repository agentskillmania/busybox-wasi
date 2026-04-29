#!/bin/bash
# BusyBox 1.37.0 → WebAssembly 构建脚本
#
# 一行命令完成从配置到编译到验证的全流程。
# 用法: ./build_wasm.sh

set -e

WASI_SDK="${WASI_SDK:-$HOME/wasi-sdk}"
WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
JOBS="$(sysctl -n hw.ncpu 2>/dev/null || nproc)"

echo "=== 编译 busybox 1.37.0 → WASM ==="

# 从 defconfig 生成 .config
echo "--- 从 configs/wasm_defconfig 生成 .config ---"
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" wasm_defconfig

# 清理
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" clean

# 编译
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" SKIP_STRIP=y -j"$JOBS"

# 重命名为 .wasm
cp "$PROJ_DIR/busybox" "$PROJ_DIR/busybox.wasm" 2>/dev/null || \
cp "$PROJ_DIR/busybox_unstripped" "$PROJ_DIR/busybox.wasm"

echo ""
echo "=== 构建完成 ==="
ls -lh "$PROJ_DIR/busybox.wasm"
echo ""

# 验证
echo "=== 验证 ==="
$WASMTIME -W exceptions=y "$PROJ_DIR/busybox.wasm" echo "Hello from WASM busybox!"
echo ""
$WASMTIME -W exceptions=y "$PROJ_DIR/busybox.wasm" --list 2>&1 | wc -l | xargs -I{} echo "{} 个 applets"
echo ""
echo "--- wsh 验证 ---"
$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" wsh -c "true" 2>&1
echo ""
echo "--- 变量 ---"
$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" wsh -c 'X=hello; echo $X' 2>&1
