#!/bin/bash
# test/helper.sh — busybox.wasm TAP 测试公共框架
#
# 用法：
#   #!/bin/bash
#   source "$(dirname "$0")/../helper.sh"
#   plan 5
#   # ... 测试 ...
#   done_testing
#
# 环境变量：
#   WASMTIME      — wasmtime 路径（默认 $HOME/bin/wasmtime）
#   BUSYBOX_WASM  — busybox.wasm 路径（默认 $PROJ_ROOT/busybox.wasm）
#   KEEP_TMP      — 设为 y 保留失败时的临时目录
#   VERBOSE       — 设为 y 显示详细输出

set -u

# ========================= 配置 =========================

_PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
BUSYBOX_WASM="${BUSYBOX_WASM:-$_PROJ_ROOT/busybox.wasm}"

# wasmtime 标志
_WASM_FLAGS="-W exceptions=y"
# 网络标志：TCP + UDP + 继承宿主网络 + DNS
_WASM_NET_FLAGS="-S tcp=y -S udp=y -S inherit-network -S allow-ip-name-lookup=y"

# TAP 状态
_TEST_COUNT=0
_PLANNED_TESTS=0
_PLAN_SET=0
_FAILED=0

# 临时目录
TMPDIR=""
_TEST_TMPDIR=""
_WASM_DIR=""

# ========================= 临时目录 =========================

setup() {
    _TEST_TMPDIR="$(mktemp -d "/tmp/bbtest.XXXXXX")"
    TMPDIR="$_TEST_TMPDIR"
    _WASM_DIR="$_TEST_TMPDIR"
}

teardown() {
    if [[ -n "$_TEST_TMPDIR" && -d "$_TEST_TMPDIR" ]]; then
        if [[ "${KEEP_TMP:-}" == "y" && _FAILED -gt 0 ]]; then
            echo "# 保留临时目录: $_TEST_TMPDIR" >&2
        else
            rm -rf "$_TEST_TMPDIR"
        fi
    fi
}

# ========================= TAP 函数 =========================

# plan <N> — 声明计划测试数量
plan() {
    _PLANNED_TESTS="$1"
    _PLAN_SET=1
    echo "1..$_PLANNED_TESTS"
}

# ok <描述> — 测试通过
ok() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    echo "ok $_TEST_COUNT - $1"
}

# not_ok <描述> — 测试失败
not_ok() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    _FAILED=$(( _FAILED + 1 ))
    echo "not ok $_TEST_COUNT - $1"
}

# is <实际> <期望> <描述> — 精确比较
is() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    local got="$1" expected="$2" desc="$3"
    if [[ "$got" == "$expected" ]]; then
        echo "ok $_TEST_COUNT - $desc"
    else
        _FAILED=$(( _FAILED + 1 ))
        echo "not ok $_TEST_COUNT - $desc"
        echo "#   实际:   '$got'" >&2
        echo "#   期望:   '$expected'" >&2
    fi
}

# isnt <实际> <不期望> <描述> — 不等于比较
isnt() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    local got="$1" unexpected="$2" desc="$3"
    if [[ "$got" != "$unexpected" ]]; then
        echo "ok $_TEST_COUNT - $desc"
    else
        _FAILED=$(( _FAILED + 1 ))
        echo "not ok $_TEST_COUNT - $desc"
        echo "#   不期望的值: '$got'" >&2
    fi
}

# cmp_ok <实际> <操作符> <期望> <描述> — 数值比较
# 支持: ==, !=, <, >, <=, >=
cmp_ok() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    local got=$(echo "$1" | tr -d '[:space:]')
    local op="$2"
    local expected=$(echo "$3" | tr -d '[:space:]')
    local desc="$4"
    local result
    case "$op" in
        "==")  [[ $got -eq $expected ]] ;;
        "!=")  [[ $got -ne $expected ]] ;;
        "<")   [[ $got -lt $expected ]] ;;
        ">")   [[ $got -gt $expected ]] ;;
        "<=")  [[ $got -le $expected ]] ;;
        ">=")  [[ $got -ge $expected ]] ;;
        *)     false ;;
    esac
    if [[ $? -eq 0 ]]; then
        echo "ok $_TEST_COUNT - $desc"
    else
        _FAILED=$(( _FAILED + 1 ))
        echo "not ok $_TEST_COUNT - $desc"
        echo "#   实际: $got, 期望: $op $expected" >&2
    fi
}

# like <实际> <正则> <描述> — 正则匹配
like() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    local got="$1" regex="$2" desc="$3"
    if [[ "$got" =~ $regex ]]; then
        echo "ok $_TEST_COUNT - $desc"
    else
        _FAILED=$(( _FAILED + 1 ))
        echo "not ok $_TEST_COUNT - $desc"
        echo "#   '$got' 不匹配 /$regex/" >&2
    fi
}

# unlike <实际> <正则> <描述> — 不匹配正则
unlike() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    local got="$1" regex="$2" desc="$3"
    if [[ ! "$got" =~ $regex ]]; then
        echo "ok $_TEST_COUNT - $desc"
    else
        _FAILED=$(( _FAILED + 1 ))
        echo "not ok $_TEST_COUNT - $desc"
        echo "#   '$got' 不应匹配 /$regex/" >&2
    fi
}

# skip <原因> — 跳过一个测试
skip() {
    _TEST_COUNT=$(( _TEST_COUNT + 1 ))
    echo "ok $_TEST_COUNT - # SKIP $1"
}

# skip_if <条件命令> <原因> — 条件命令退出码为 0 时跳过
# 用法: skip_if test -z "$VAR" "原因"  或  skip_if true "原因"
# 返回 0 表示已跳过，1 表示未跳过
skip_if() {
    local reason="${@: -1}"
    local cmd=("${@:1:$#-1}")
    if "${cmd[@]}" >/dev/null 2>&1; then
        skip "$reason"
        return 0
    fi
    return 1
}

# done_testing — 结束测试，清理并退出
done_testing() {
    if [[ $_PLAN_SET -eq 1 && $_TEST_COUNT -ne $_PLANNED_TESTS ]]; then
        echo "# 计划 $_PLANNED_TESTS 个测试，实际运行 $_TEST_COUNT 个" >&2
    fi
    teardown
    exit $_FAILED
}

# ========================= 命令执行 =========================

# bb_run <applet> [args...] — 标准（带 --dir）
# 设置: _BB_EXIT, _BB_STDOUT
bb_run() {
    local applet="$1"; shift
    local stderr_dest="/dev/null"
    [[ "${VERBOSE:-}" == "y" ]] && stderr_dest="/dev/stderr"

    _BB_STDOUT=$($WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" \
        "$BUSYBOX_WASM" "$applet" "$@" 2>"$stderr_dest") && _BB_EXIT=0 || _BB_EXIT=$?
}

# bb_run_capture <applet> [args...] — 同时捕获 stdout 和 stderr
# 设置: _BB_EXIT, _BB_STDOUT, _BB_STDERR
bb_run_capture() {
    local applet="$1"; shift
    local tmperr="$_TEST_TMPDIR/_stderr.txt"

    _BB_STDOUT=$($WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" \
        "$BUSYBOX_WASM" "$applet" "$@" 2>"$tmperr") && _BB_EXIT=0 || _BB_EXIT=$?
    _BB_STDERR="$(cat "$tmperr" 2>/dev/null)" || _BB_STDERR=""
}

# bb_run_stdin <stdin数据> <applet> [args...] — 通过 stdin 传入数据
# 设置: _BB_EXIT, _BB_STDOUT
bb_run_stdin() {
    local stdin_data="$1"; shift
    local applet="$1"; shift
    local stderr_dest="/dev/null"
    [[ "${VERBOSE:-}" == "y" ]] && stderr_dest="/dev/stderr"

    _BB_STDOUT=$(printf '%s' "$stdin_data" | \
        $WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" \
        "$BUSYBOX_WASM" "$applet" "$@" 2>"$stderr_dest") && _BB_EXIT=0 || _BB_EXIT=$?
}

# bb_run_env <applet> [args...] — 带环境变量（传入 HOME/PATH 等）
# 设置: _BB_EXIT, _BB_STDOUT
bb_run_env() {
    local applet="$1"; shift
    local stderr_dest="/dev/null"
    [[ "${VERBOSE:-}" == "y" ]] && stderr_dest="/dev/stderr"

    _BB_STDOUT=$($WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" \
        --env=HOME=/root --env=PATH=/usr/bin:/bin \
        "$BUSYBOX_WASM" "$applet" "$@" 2>"$stderr_dest") && _BB_EXIT=0 || _BB_EXIT=$?
}

# bb_run_net <applet> [args...] — 带网络标志
# 设置: _BB_EXIT, _BB_STDOUT
bb_run_net() {
    local applet="$1"; shift
    local stderr_dest="/dev/null"
    [[ "${VERBOSE:-}" == "y" ]] && stderr_dest="/dev/stderr"

    _BB_STDOUT=$($WASMTIME $_WASM_FLAGS $_WASM_NET_FLAGS \
        --dir="$_WASM_DIR" \
        "$BUSYBOX_WASM" "$applet" "$@" 2>"$stderr_dest") && _BB_EXIT=0 || _BB_EXIT=$?
}

# bb_run_wsh <命令> — 通过 wsh -c 执行
# 注意：wsh 管道临时文件写入 /tmp，需要额外挂载 /tmp
# 设置: _BB_EXIT, _BB_STDOUT
bb_run_wsh() {
    local cmd="$1"
    local tmperr="$_TEST_TMPDIR/_wsh_stderr.txt"

    _BB_STDOUT=$($WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" --dir=/tmp \
        "$BUSYBOX_WASM" wsh -c "$cmd" 2>"$tmperr") && _BB_EXIT=0 || _BB_EXIT=$?
    # wsh 管道输出到 stderr，合并到 _BB_STDOUT
    local stderr_out
    stderr_out="$(cat "$tmperr" 2>/dev/null)" || stderr_out=""
    if [[ -n "$stderr_out" ]]; then
        if [[ -n "$_BB_STDOUT" ]]; then
            _BB_STDOUT="$_BB_STDOUT"$'\n'"$stderr_out"
        else
            _BB_STDOUT="$stderr_out"
        fi
    fi
}

# ========================= 文件辅助 =========================

# mkfile <相对路径> [内容] — 在 TMPDIR 创建文件，返回完整路径
mkfile() {
    local relpath="$1"
    local contents="${2:-}"
    local fullpath="$_TEST_TMPDIR/$relpath"
    mkdir -p "$(dirname "$fullpath")"
    printf '%s' "$contents" > "$fullpath"
    echo "$fullpath"
}

# mkfile_bin <相对路径> <hex> — 从十六进制字符串创建二进制文件
mkfile_bin() {
    local relpath="$1" hex="$2"
    local fullpath="$_TEST_TMPDIR/$relpath"
    mkdir -p "$(dirname "$fullpath")"
    echo "$hex" | xxd -r -p > "$fullpath"
    echo "$fullpath"
}

# bb_run_timeout <秒> <applet> [args...] — 带超时的执行
# 超时后进程被杀，_BB_EXIT 设为 124
# 设置: _BB_EXIT, _BB_STDOUT
bb_run_timeout() {
    local timeout_sec="$1"; shift
    local applet="$1"; shift
    local stderr_dest="/dev/null"
    [[ "${VERBOSE:-}" == "y" ]] && stderr_dest="/dev/stderr"
    local outfile="$_TEST_TMPDIR/_timeout_stdout.txt"

    $WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" \
        "$BUSYBOX_WASM" "$applet" "$@" \
        >"$outfile" 2>"$stderr_dest" &
    local pid=$!
    local count=0
    while kill -0 $pid 2>/dev/null; do
        if [[ $count -ge $timeout_sec ]]; then
            kill $pid 2>/dev/null
            wait $pid 2>/dev/null
            _BB_STDOUT="$(cat "$outfile" 2>/dev/null)" || _BB_STDOUT=""
            _BB_EXIT=124
            return
        fi
        sleep 1
        count=$(( count + 1 ))
    done
    wait $pid 2>/dev/null
    _BB_EXIT=$?
    _BB_STDOUT="$(cat "$outfile" 2>/dev/null)" || _BB_STDOUT=""
}

# ========================= 启动 =========================

# source 时自动执行 setup
setup
