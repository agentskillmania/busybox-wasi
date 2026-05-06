#!/bin/bash
# busybox-wasi 测试统一入口
#
# 用法:
#   bash test/run-all.sh              # 运行全部测试
#   bash test/run-all.sh unit         # 只运行 unit 测试
#   bash test/run-all.sh integration  # 只运行 integration 测试
#   bash test/run-all.sh wsh          # 只运行 wsh 相关测试
#
# 环境变量:
#   WASMTIME      — wasmtime 路径
#   BUSYBOX_WASM  — busybox.wasm 路径
#   VERBOSE       — 设为 y 显示详细输出

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 检查产物
BUSYBOX_WASM="${BUSYBOX_WASM:-$PROJ_ROOT/busybox.wasm}"
if [ ! -f "$BUSYBOX_WASM" ]; then
	echo "Error: busybox.wasm not found at $BUSYBOX_WASM" >&2
	echo "Run: ./build_wasm.sh" >&2
	exit 1
fi

# 解析参数
MODE="${1:-all}"

UNIT_DIR="$SCRIPT_DIR/unit"
INTEGRATION_DIR="$SCRIPT_DIR/integration"

FAILED=0
PASSED=0
TOTAL=0

run_test_file() {
	local file="$1"
	local name
	name="$(basename "$file")"
	echo ""
	echo "========== $name =========="
	if bash "$file"; then
		PASSED=$((PASSED + 1))
	else
		FAILED=$((FAILED + 1))
		echo "FAILED: $name" >&2
	fi
	TOTAL=$((TOTAL + 1))
}

echo "========================================"
echo "busybox-wasi Test Runner"
echo "========================================"
echo "BUSYBOX_WASM: $BUSYBOX_WASM"
echo "MODE: $MODE"
echo ""

# Unit 测试
if [ "$MODE" = "all" ] || [ "$MODE" = "unit" ]; then
	echo "--- Unit Tests ---"
	for f in "$UNIT_DIR"/*.test.sh; do
		[ -f "$f" ] || continue
		run_test_file "$f"
	done
fi

# Integration 测试
if [ "$MODE" = "all" ] || [ "$MODE" = "integration" ]; then
	echo ""
	echo "--- Integration Tests ---"
	for f in "$INTEGRATION_DIR"/*.test.sh; do
		[ -f "$f" ] || continue
		run_test_file "$f"
	done
fi

# WSH 相关测试（unit + integration 中的 wsh 测试）
if [ "$MODE" = "wsh" ]; then
	echo "--- WSH Unit Tests ---"
	[ -f "$UNIT_DIR/wsh.test.sh" ] && run_test_file "$UNIT_DIR/wsh.test.sh"

	echo ""
	echo "--- WSH Integration Tests ---"
	for f in "$INTEGRATION_DIR"/wsh_*.test.sh; do
		[ -f "$f" ] || continue
		run_test_file "$f"
	done
	[ -f "$INTEGRATION_DIR/composed.test.sh" ] && run_test_file "$INTEGRATION_DIR/composed.test.sh"
fi

# 汇总
echo ""
echo "========================================"
echo "Summary: $PASSED passed, $FAILED failed, $TOTAL total"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
	exit 1
fi
exit 0
