#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# unix2dos 在 WASI 中：
# - 原地转换不可用（需要 mkstemp 创建临时文件，ENOSYS）
# - -n 选项不被支持（BusyBox unix2dos 没有 -n 选项）
# - 通过 stdin/stdout 模式可以正常工作

# unix2dos 通过 stdin/stdout 模式转换
printf 'hello\nworld\n' > "$_TEST_TMPDIR/unix.txt"
bb_run_stdin "$(cat "$_TEST_TMPDIR/unix.txt")" unix2dos
is "$_BB_EXIT" "0" "unix2dos 通过 stdin/stdout 转换不崩溃"

# 验证转换后包含 CRLF（通过管道模式）
printf 'hello\nworld\n' | $WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" \
    "$BUSYBOX_WASM" unix2dos > "$_TEST_TMPDIR/converted.txt" 2>/dev/null
converted=$(cat "$_TEST_TMPDIR/converted.txt")
like "$converted" $'\r\n' "unix2dos 转换后包含 \\r\\n"

# 验证内容保留
like "$converted" "hello" "unix2dos 转换后内容保留"
like "$converted" "world" "unix2dos 转换后内容完整"

# unix2dos 原地转换在 WASI 中不可用（mkstemp ENOSYS）
printf 'line1\nline2\n' > "$_TEST_TMPDIR/inplace.txt"
bb_run unix2dos "$_TEST_TMPDIR/inplace.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "unix2dos 原地转换在 WASI 中不可用（mkstemp ENOSYS）"

# unix2dos -n 不被 BusyBox 支持（unrecognized option）
printf 'line1\nline2\n' > "$_TEST_TMPDIR/unix2.txt"
bb_run unix2dos -n "$_TEST_TMPDIR/unix2.txt" "$_TEST_TMPDIR/dos2.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "unix2dos -n 不被 BusyBox 支持"

done_testing
