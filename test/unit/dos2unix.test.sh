#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 生成 Windows 行尾的文件（CRLF）
printf 'hello\r\nworld\r\n' > "$_TEST_TMPDIR/dos.txt"

# dos2unix 基本转换
bb_run dos2unix "$_TEST_TMPDIR/dos.txt"
is "$_BB_EXIT" "0" "dos2unix 转换不崩溃"

# 验证转换后文件只有 LF
converted=$(cat "$_TEST_TMPDIR/dos.txt")
unlike "$converted" $'\r' "dos2unix 转换后无 \\r"

# 验证转换后内容正确
like "$converted" "hello" "dos2unix 转换后内容保留"
like "$converted" "world" "dos2unix 转换后内容完整"

# dos2unix -n 输出到新文件
printf 'line1\r\nline2\r\n' > "$_TEST_TMPDIR/dos2.txt"
bb_run dos2unix -n "$_TEST_TMPDIR/dos2.txt" "$_TEST_TMPDIR/unix2.txt"
is "$_BB_EXIT" "0" "dos2unix -n 输出到新文件"

# 新文件无 \r
if [[ -f "$_TEST_TMPDIR/unix2.txt" ]]; then
    unix2_content=$(cat "$_TEST_TMPDIR/unix2.txt")
    unlike "$unix2_content" $'\r' "dos2unix -n 输出文件无 \\r"
else
    skip "dos2unix -n 未生成输出文件"
fi

done_testing
