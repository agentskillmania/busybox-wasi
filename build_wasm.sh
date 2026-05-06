#!/bin/bash
# BusyBox 1.37.0 → WebAssembly 构建脚本
#
# 用法:
#   ./build_wasm.sh              老模式（默认）— 直接运行
#   ./build_wasm.sh --component  Component 模式 — 需要 wac 组合

set -e

COMPONENT_MODE=""
if [ "$1" = "--component" ]; then
	COMPONENT_MODE="y"
fi

WASI_SDK="${WASI_SDK:-$HOME/wasi-sdk}"
WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
JOBS="$(sysctl -n hw.ncpu 2>/dev/null || nproc)"

if [ -n "$COMPONENT_MODE" ]; then
	echo "=== 编译 busybox → WASM (Component 模式) ==="
else
	echo "=== 编译 busybox → WASM (老模式) ==="
fi

# 从 defconfig 生成 .config
echo "--- 从 configs/wasm_defconfig 生成 .config ---"
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" wasm_defconfig

# 清理
make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" clean

# Component 模式：clean 后重新生成 host 绑定（clean 会删除 .o）
if [ -n "$COMPONENT_MODE" ]; then
	echo "--- 生成 Component host 绑定 ---"
	bash "$PROJ_DIR/generate_host_bindings.sh"
fi

# 编译
if [ -n "$COMPONENT_MODE" ]; then
	make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" SKIP_STRIP=y COMPONENT_MODE=y -j"$JOBS"
else
	make -C "$PROJ_DIR" ARCH=wasm32 WASI_SDK="$WASI_SDK" SKIP_STRIP=y -j"$JOBS"
fi

# 产物处理
if [ -n "$COMPONENT_MODE" ]; then
	cp "$PROJ_DIR/busybox_unstripped" "$PROJ_DIR/busybox-component.wasm"
	echo ""
	echo "=== Host Component 构建完成 ==="
	ls -lh "$PROJ_DIR/busybox-component.wasm"
	echo ""

	# --- Compose with guest components ---
	echo "=== Composing guest components ==="

	GIT_GUEST="$PROJ_DIR/../libgit2/build-component/git-guest.wasm"
	MPY_GUEST="$PROJ_DIR/../micropython-1.27.0-wasi/ports/wasi/build-component/micropython-guest.wasm"

	if ! command -v wac &>/dev/null; then
		echo "Warning: wac not found. Skipping composition."
		echo "Install wac: cargo install wac-cli"
	elif [ ! -f "$GIT_GUEST" ]; then
		echo "Warning: git-guest.wasm not found at $GIT_GUEST"
		echo "Run: cd ../libgit2 && ./build_component.sh"
	elif [ ! -f "$MPY_GUEST" ]; then
		echo "Warning: micropython-guest.wasm not found at $MPY_GUEST"
		echo "Run: cd ../micropython-1.27.0-wasi/ports/wasi && ./build_component.sh"
	else
		echo "Composing busybox + git + python ..."
		wac plug "$PROJ_DIR/busybox-component.wasm" \
			--plug "$GIT_GUEST" \
			--plug "$MPY_GUEST" \
			-o "$PROJ_DIR/composed-busybox.wasm"
		echo ""
		echo "=== Composition complete ==="
		ls -lh "$PROJ_DIR/composed-busybox.wasm"
		echo ""
		echo "Run: wasmtime run -W exceptions=y --dir=/tmp ./composed-busybox.wasm wsh -c 'git status'"
		echo "Run: wasmtime run -W exceptions=y --dir=/tmp ./composed-busybox.wasm wsh -c 'python print(\"hello\")'"
	fi
else
	cp "$PROJ_DIR/busybox" "$PROJ_DIR/busybox.wasm" 2>/dev/null || \
	cp "$PROJ_DIR/busybox_unstripped" "$PROJ_DIR/busybox.wasm"
	echo ""
	echo "=== 构建完成 ==="
	ls -lh "$PROJ_DIR/busybox.wasm"
	echo ""
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
fi
