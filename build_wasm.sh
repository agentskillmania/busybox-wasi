#!/bin/bash
# BusyBox 1.37.0 → WebAssembly 构建脚本
#
# 默认编译为 WASI Component 模式，自动组合 git + python guest。
# 产物: busybox.wasm
#
# 依赖:
#   - wasi-sdk  (环境变量 WASI_SDK 或 $HOME/wasi-sdk)
#   - wasmtime  (环境变量 WASMTIME 或 $HOME/bin/wasmtime)
#   - wit-bindgen 0.57+
#   - wac       (cargo install wac-cli)
#
# 如果 guest components 未编译，脚本会生成 host 并提示手动组合。

set -e

WASI_SDK="${WASI_SDK:-$HOME/wasi-sdk}"
WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
JOBS="$(sysctl -n hw.ncpu 2>/dev/null || nproc)"

# ===================== 依赖检查 =====================

die() {
	echo "Error: $1" >&2
	exit 1
}

if [ ! -d "$WASI_SDK" ]; then
	die "wasi-sdk not found at $WASI_SDK"
fi

if [ ! -x "$WASI_SDK/bin/wasm32-wasip2-clang" ]; then
	die "wasi-sdk clang not found at $WASI_SDK/bin/wasm32-wasip2-clang"
fi

if ! command -v wit-bindgen &>/dev/null; then
	die "wit-bindgen not found. Install: cargo install wit-bindgen-cli"
fi

# wasmtime 仅用于验证，可选
HAVE_WASMTIME=0
if [ -x "$WASMTIME" ]; then
	HAVE_WASMTIME=1
fi

# ===================== Guest 组件路径 =====================

GIT_GUEST="$PROJ_DIR/../libgit2/build-component/git-guest.wasm"
MPY_GUEST="$PROJ_DIR/../micropython-1.27.0-wasi/ports/wasi/build-component/micropython-guest.wasm"

# 检查 guest 是否可用
HAVE_GIT=0
HAVE_MPY=0
if [ -f "$GIT_GUEST" ]; then
	HAVE_GIT=1
fi
if [ -f "$MPY_GUEST" ]; then
	HAVE_MPY=1
fi

# ===================== 构建 =====================

echo "=== Building busybox.wasm (WASI Component Mode) ==="

# 1. 从 defconfig 生成 .config
echo "--- Generating .config from configs/wasm_defconfig ---"
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" wasm_defconfig

# 2. 清理
echo "--- Cleaning ---"
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" clean

# 3. 生成 host 绑定
echo "--- Generating host bindings ---"
bash "$PROJ_DIR/generate_host_bindings.sh"

# 4. 编译（始终 COMPONENT_MODE）
echo "--- Compiling ---"
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" SKIP_STRIP=y COMPONENT_MODE=y -j"$JOBS"

# 5. 复制 host 产物
mkdir -p "$PROJ_DIR/build"
cp "$PROJ_DIR/busybox_unstripped" "$PROJ_DIR/build/busybox-host.wasm"

# 6. 组合（如果依赖齐全）
if command -v wac &>/dev/null && [ "$HAVE_GIT" -eq 1 ] && [ "$HAVE_MPY" -eq 1 ]; then
	echo ""
	echo "=== Composing with guest components ==="
	wac plug "$PROJ_DIR/build/busybox-host.wasm" \
		--plug "$GIT_GUEST" \
		--plug "$MPY_GUEST" \
		-o "$PROJ_DIR/busybox.wasm"
	echo ""
	echo "=== Build complete ==="
	ls -lh "$PROJ_DIR/busybox.wasm"
	echo ""

	# 验证
	if [ "$HAVE_WASMTIME" -eq 1 ]; then
		echo "--- Verification ---"
		$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" echo "Hello from WASM busybox!"
		echo ""
		$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" wsh -c "true"
		echo ""
		$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" wsh -c 'git --version'
		echo ""
		$WASMTIME -W exceptions=y --dir=/tmp "$PROJ_DIR/busybox.wasm" wsh -c 'python -c "print(42)"'
	fi
else
	# Guest 缺失，只生成 host
	echo ""
	echo "=== Host build complete (guests not composed) ==="
	cp "$PROJ_DIR/build/busybox-host.wasm" "$PROJ_DIR/busybox.wasm"
	ls -lh "$PROJ_DIR/busybox.wasm"
	echo ""

	if [ "$HAVE_GIT" -eq 0 ]; then
		echo "Warning: git-guest.wasm not found at $GIT_GUEST"
		echo "  Run: cd ../libgit2 && ./build_component.sh"
	fi
	if [ "$HAVE_MPY" -eq 0 ]; then
		echo "Warning: micropython-guest.wasm not found at $MPY_GUEST"
		echo "  Run: cd ../micropython-1.27.0-wasi/ports/wasi && ./build_component.sh"
	fi
	if ! command -v wac &>/dev/null; then
		echo "Warning: wac not found. Install: cargo install wac-cli"
	fi
	echo ""
	echo "To compose after building guests:"
	echo "  wac plug ./build/busybox-host.wasm --plug $GIT_GUEST --plug $MPY_GUEST -o ./busybox.wasm"
fi
