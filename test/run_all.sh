#!/bin/bash
# test/run_all.sh — busybox.wasm 测试运行器
#
# 用法：
#   test/run_all.sh                     # 运行全部
#   test/run_all.sh cat                 # 运行 cat 测试
#   test/run_all.sh unit/cat.test.sh    # 指定文件
#   test/run_all.sh --list              # 列出所有测试
#   test/run_all.sh --category core     # 按分类运行
#   test/run_all.sh --category network  # 仅网络测试
#
# 兼容 bash 3.2+（macOS）

set -euo pipefail

PROJ_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$PROJ_ROOT/test"
UNIT_DIR="$TEST_DIR/unit"

# 分类映射（bash 3.2 兼容：用函数代替关联数组）
_cat_cmds() {
    case "$1" in
        core)      echo "cat cp mv rm ls mkdir rmdir ln link unlink touch chmod truncate dd install mktemp mkfifo basename dirname pwd realpath readlink stat du df wc head tail tac tee sort uniq comm cut tr paste fold expand unexpand nl split shuf seq od xxd hd hexdump rev strings sum cksum crc32 md5sum sha1sum sha256sum sha3sum sha512sum base32 base64 uuencode uudecode echo printf env printenv test_cmd expr factor true false yes sleep usleep date uname arch tty groups tsort shred nohup nice timeout sync fsync dos2unix unix2dos which ascii cal dmesg getopt strings rev" ;;
        text)      echo "grep egrep fgrep sed awk diff cmp patch" ;;
        compress)  echo "gzip gunzip zcat bzip2 bunzip2 bzcat xz unxz xzcat lzma unlzma lzcat lzop tar cpio unzip dpkg dpkg_deb rpm rpm2cpio" ;;
        network)   echo "wget nc telnet nslookup ftpget ftpput tcpsvd udpsvd whois" ;;
        calc)      echo "bc dc" ;;
        shell)     echo "wsh" ;;
        editors)   echo "vi ed" ;;
        misc)      echo "pipe_progress run_parts chroot" ;;
        *)         echo "" ;;
    esac
}

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 计数器
TOTAL=0
PASSED=0
FAILED=0
FAILED_TESTS=""

# ========================= 函数 =========================

discover_tests() {
    if [[ $# -eq 0 ]]; then
        find "$UNIT_DIR" -name '*.test.sh' 2>/dev/null | sort
        return
    fi

    local arg="$1"; shift
    case "$arg" in
        --list)
            find "$UNIT_DIR" -name '*.test.sh' 2>/dev/null | sort | while read -r f; do
                basename "$f" .test.sh
            done
            exit 0
            ;;
        --category)
            for cat in "$@"; do
                local cmds
                cmds="$(_cat_cmds "$cat")"
                for cmd in $cmds; do
                    local tf="$UNIT_DIR/${cmd}.test.sh"
                    [[ -f "$tf" ]] && echo "$tf"
                done
            done
            ;;
        *)
            # 单个命令名或文件路径
            for name in "$arg" "$@"; do
                if [[ -f "$name" ]]; then
                    echo "$name"
                elif [[ -f "$UNIT_DIR/$name" ]]; then
                    echo "$UNIT_DIR/$name"
                elif [[ -f "$UNIT_DIR/${name}.test.sh" ]]; then
                    echo "$UNIT_DIR/${name}.test.sh"
                else
                    echo "ERROR: 测试未找到: $name" >&2
                    exit 1
                fi
            done
            ;;
    esac
}

run_test() {
    local testfile="$1"
    local testname
    testname="$(basename "$testfile" .test.sh)"

    TOTAL=$((TOTAL + 1))

    local output exitcode
    output=$("$testfile" 2>&1) && exitcode=$? || exitcode=$?

    # 解析 TAP 输出
    local test_passed=0 test_failed=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^not\ ok ]]; then
            test_failed=$((test_failed + 1))
        elif [[ "$line" =~ ^ok ]]; then
            test_passed=$((test_passed + 1))
        fi
    done <<< "$output"

    # 输出结果
    if [[ $test_failed -eq 0 && $exitcode -eq 0 ]]; then
        PASSED=$((PASSED + 1))
        echo -e "${GREEN}PASS${NC} $testname ($test_passed assertions)"
    else
        FAILED=$((FAILED + 1))
        FAILED_TESTS="$FAILED_TESTS $testname"
        echo -e "${RED}FAIL${NC} $testname ($test_failed failed, $test_passed passed)"
        echo "$output" | grep -E '^(not ok|#)' | sed 's/^/  /'
    fi
}

# ========================= 前置检查 =========================

WASMTIME_BIN="${WASMTIME:-$HOME/bin/wasmtime}"
BUSYBOX_WASM_BIN="${BUSYBOX_WASM:-$PROJ_ROOT/busybox.wasm}"

if ! command -v "$WASMTIME_BIN" &>/dev/null; then
    echo "ERROR: wasmtime 未找到: $WASMTIME_BIN" >&2
    exit 1
fi

if [[ ! -f "$BUSYBOX_WASM_BIN" ]]; then
    echo "ERROR: busybox.wasm 未找到: $BUSYBOX_WASM_BIN" >&2
    exit 1
fi

# ========================= 主逻辑 =========================

echo "=== busybox.wasm 测试套件 ==="
echo "二进制: $BUSYBOX_WASM_BIN"
echo "运行时: $WASMTIME_BIN"
echo ""

# 收集测试文件（兼容 bash 3.2，不用 mapfile）
TESTS=()
while IFS= read -r line; do
    TESTS+=("$line")
done < <(discover_tests "$@")

if [[ ${#TESTS[@]} -eq 0 ]]; then
    echo "未找到测试文件。"
    exit 0
fi

echo "运行 ${#TESTS[@]} 个测试..."
echo ""

START_TIME=$SECONDS

for t in "${TESTS[@]}"; do
    run_test "$t"
done

ELAPSED=$(( SECONDS - START_TIME ))

# 汇总
echo ""
echo "=== 汇总 ==="
echo "总计: $TOTAL  通过: $PASSED  失败: $FAILED"
echo "耗时: ${ELAPSED}s"

if [[ -n "$FAILED_TESTS" ]]; then
    echo ""
    echo "失败的测试:"
    for ft in $FAILED_TESTS; do
        echo "  - $ft"
    done
    exit 1
fi

exit 0
