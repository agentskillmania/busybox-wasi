#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 生成测试文件
file=$(mkfile "test.bin" "Hello")

# hexdump 基本调用
bb_run hexdump "$file"
is "$_BB_EXIT" "0" "hexdump 不崩溃"

# 输出非空
bb_run hexdump "$file"
isnt "$_BB_STDOUT" "" "hexdump 输出非空"

# hexdump -C 经典格式
bb_run hexdump -C "$file"
is "$_BB_EXIT" "0" "hexdump -C 不崩溃"

# hexdump -C 输出包含十六进制和 ASCII
bb_run hexdump -C "$file"
like "$_BB_STDOUT" "[0-9a-f]" "hexdump -C 输出包含十六进制数字"

# hexdump -C 输出包含 ASCII 部分
bb_run hexdump -C "$file"
like "$_BB_STDOUT" "Hello" "hexdump -C 输出包含 ASCII 部分"

# 通过 stdin
bb_run_stdin "Hello" hexdump
is "$_BB_EXIT" "0" "hexdump 通过 stdin 不崩溃"

# 不存在的文件
bb_run hexdump "$_TEST_TMPDIR/nonexistent.bin"
cmp_ok "$_BB_EXIT" "!=" "0" "hexdump 不存在的文件返回非零"

# 无参数应报错
bb_run hexdump
cmp_ok "$_BB_EXIT" "!=" "0" "hexdump 无参数返回非零"

done_testing
