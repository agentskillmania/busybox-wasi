#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 生成 Unix 行尾的文件（LF）
printf 'hello\nworld\n' > "$_TEST_TMPDIR/unix.txt"

# unix2dos 基本转换
bb_run unix2dos "$_TEST_TMPDIR/unix.txt"
is "$_BB_EXIT" "0" "unix2dos 转换不崩溃"

# 验证转换后文件包含 CRLF
converted=$(cat "$_TEST_TMPDIR/unix.txt")
like "$converted" $'\r\n' "unix2dos 转换后包含 \\r\\n"

# 验证内容保留
like "$converted" "hello" "unix2dos 转换后内容保留"
like "$converted" "world" "unix2dos 转换后内容完整"

# unix2dos -n 输出到新文件
printf 'line1\nline2\n' > "$_TEST_TMPDIR/unix2.txt"
bb_run unix2dos -n "$_TEST_TMPDIR/unix2.txt" "$_TEST_TMPDIR/dos2.txt"
is "$_BB_EXIT" "0" "unix2dos -n 输出到新文件"

# 新文件包含 CRLF
if [[ -f "$_TEST_TMPDIR/dos2.txt" ]]; then
    dos2_content=$(cat "$_TEST_TMPDIR/dos2.txt")
    like "$dos2_content" $'\r\n' "unix2dos -n 输出文件包含 \\r\\n"
else
    skip "unix2dos -n 未生成输出文件"
fi

done_testing
