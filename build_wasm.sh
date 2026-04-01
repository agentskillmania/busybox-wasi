#!/bin/bash
# BusyBox 1.37.0 → WebAssembly 构建脚本
# 使用 wasi-sdk 编译，输出 busybox.wasm
# 支持 preview2（POSIX socket 开箱即用）

set -e

WASI_SDK="${WASI_SDK:-$HOME/wasi-sdk}"
WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSROOT="$WASI_SDK/share/wasi-sysroot"

# Preview2 编译器：POSIX socket 已内置
# 注意：中间步骤 ld -r 需要 wasm-ld（wasm-component-ld 不支持 -r）
# 用 wrapper 过滤 -nostdlib 等不兼容参数
CC="$WASI_SDK/bin/wasm32-wasip2-clang --sysroot=$SYSROOT -I$PROJ_DIR/wasi_include -mllvm -wasm-enable-sjlj -mllvm -wasm-use-legacy-eh=0"
AR="$WASI_SDK/bin/llvm-ar"
LD="$PROJ_DIR/wasm-ld-wrapper.sh"
OUTPUT="$PROJ_DIR/busybox.wasm"

echo "=== 编译 busybox 1.37.0 → WASM (preview2) ==="

# 第一步：编译所有源文件
# 链接阶段在 make 中会因 undefined symbol 失败，这是预期的，
# 我们用 --allow-undefined 在第四步单独链接
echo "[1/5] 编译源文件..."
make -j$(sysctl -n hw.ncpu) AR="$AR" CC="$CC" LD="$LD" SKIP_STRIP=y 2>&1 || true

# 第二步：收集所有 WASM 目标文件
echo "[2/5] 收集目标文件..."
LIBS=()
for f in $(find . -name "lib.a" -type f | sort); do
    ftype=$(file "$f" 2>/dev/null)
    if echo "$ftype" | grep -qi "current ar archive"; then
        LIBS+=("$f")
    fi
done

# 第三步：编译 wsh（WASM Shell，不走 BusyBox 构建系统）
echo "[3/5] 编译 wsh..."
$CC \
  -I"$PROJ_DIR/shell" \
  -c "$PROJ_DIR/shell/wsh.c" -o wsh_main.o
$CC \
  -I"$PROJ_DIR/shell" \
  -c "$PROJ_DIR/shell/wsh_pipe.c" -o wsh_pipe.o

# 第四步：编译 stub
echo "[4/5] 编译 wasi_stubs.c..."
$CC \
  -D_WASI_EMULATED_SIGNAL \
  -D_WASI_EMULATED_MMAN \
  -D_WASI_EMULATED_PROCESS_CLOCKS \
  -mllvm -wasm-enable-sjlj -mllvm -wasm-use-legacy-eh=0 \
  -c "$PROJ_DIR/wasi_stubs.c" -o wasi_stubs.o

# 第五步：链接
echo "[5/5] 链接 busybox.wasm..."
$CC -static -o "$OUTPUT" \
  -Wl,--gc-sections \
  -Wl,--whole-archive "${LIBS[@]}" -Wl,--no-whole-archive \
  wsh_main.o wsh_pipe.o wasi_stubs.o \
  -lwasi-emulated-signal -lwasi-emulated-mman \
  -lwasi-emulated-process-clocks -lwasi-emulated-getpid \
  -lsetjmp \
  -Wl,--error-limit=0 -Wl,--allow-undefined

rm -f wasi_stubs.o wsh_main.o wsh_pipe.o

echo ""
echo "=== 构建完成 ==="
ls -lh "$OUTPUT"
echo ""

# 验证
echo "=== 验证 ==="
$WASMTIME -W exceptions=y "$OUTPUT" echo "Hello from WASM busybox!"
echo ""
$WASMTIME -W exceptions=y "$OUTPUT" --list 2>&1 | wc -l | xargs -I{} echo "{} 个 applets"
echo ""
echo "--- wsh 验证 ---"
$WASMTIME -W exceptions=y "$OUTPUT" wsh -c "test" 2>&1
