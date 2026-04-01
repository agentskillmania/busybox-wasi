#!/bin/bash
# BusyBox 1.37.0 → WebAssembly 构建脚本
# 使用 wasi-sdk 编译，输出 busybox.wasm

set -e

WASI_SDK="${WASI_SDK:-$HOME/wasi-sdk}"
WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSROOT="$WASI_SDK/share/wasi-sysroot"
CC="$WASI_SDK/bin/clang --target=wasm32-wasip1 --sysroot=$SYSROOT -I$PROJ_DIR/wasi_include"
AR="$WASI_SDK/bin/llvm-ar"
OUTPUT="$PROJ_DIR/busybox.wasm"

echo "=== 编译 busybox 1.37.0 → WASM ==="

# 第一步：编译所有源文件（链接阶段在 make 中会因 undefined symbol 失败，这是预期的，
# 我们用 --allow-undefined 在第四步单独链接）
echo "[1/4] 编译源文件..."
make -j$(sysctl -n hw.ncpu) AR="$AR" CC="$CC" SKIP_STRIP=y 2>&1 || true

# 第二步：收集所有 WASM 目标文件
echo "[2/4] 收集目标文件..."
LIBS=()
for f in $(find . -name "lib.a" -type f | sort); do
    ftype=$(file "$f" 2>/dev/null)
    if echo "$ftype" | grep -qi "current ar archive"; then
        LIBS+=("$f")
    fi
done

# 第三步：编译 stub
echo "[3/4] 编译 wasi_stubs.c..."
$CC -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_PROCESS_CLOCKS \
  -c "$PROJ_DIR/wasi_stubs.c" -o wasi_stubs.o

# 第四步：链接
echo "[4/4] 链接 busybox.wasm..."
$CC -static -o "$OUTPUT" \
  -Wl,--gc-sections \
  -Wl,--whole-archive "${LIBS[@]}" -Wl,--no-whole-archive \
  wasi_stubs.o \
  -lwasi-emulated-signal -lwasi-emulated-mman \
  -lwasi-emulated-process-clocks -lwasi-emulated-getpid \
  -Wl,--error-limit=0 -Wl,--allow-undefined

rm -f wasi_stubs.o

echo ""
echo "=== 构建完成 ==="
ls -lh "$OUTPUT"
echo ""

# 验证
echo "=== 验证 ==="
$WASMTIME -W exceptions=y "$OUTPUT" echo "Hello from WASM busybox!"
echo ""
$WASMTIME -W exceptions=y "$OUTPUT" --list 2>&1 | wc -l | xargs -I{} echo "{} 个 applets"
