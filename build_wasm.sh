#!/bin/bash
# BusyBox 1.37.0 → WebAssembly 构建脚本
#
# 通过 BusyBox 原生 Make/Kbuild 体系构建，arch/wasm32/Makefile 提供 WASM 工具链配置。
# 用法: ./build_wasm.sh
#   或: make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk SKIP_STRIP=y -j$(nproc)

set -e

WASI_SDK="${WASI_SDK:-$HOME/wasi-sdk}"
WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
JOBS="$(sysctl -n hw.ncpu 2>/dev/null || nproc)"

echo "=== 编译 busybox 1.37.0 → WASM (via Make/Kbuild) ==="

make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" clean
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
$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" wsh -c "test" 2>&1
echo ""
echo "--- 变量 ---"
$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" wsh -c 'X=hello; echo $X' 2>&1
