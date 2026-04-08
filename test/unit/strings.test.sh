#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# 生成包含可打印字符串的二进制文件
printf 'abc\x00def\x00hello world\x00' > "$_TEST_TMPDIR/binary.bin"

# strings 基本调用
bb_run strings "$_TEST_TMPDIR/binary.bin"
is "$_BB_EXIT" "0" "strings 不崩溃"

# 提取的字符串应包含可打印字符
bb_run strings "$_TEST_TMPDIR/binary.bin"
like "$_BB_STDOUT" "hello world" "strings 提取到 hello world"

# 通过 stdin
bb_run_stdin "$(printf 'abc\x00def\x00test\x00')" strings
like "$_BB_STDOUT" "test" "strings 通过 stdin 提取字符串"

# -n 指定最小长度
bb_run strings -n 4 "$_TEST_TMPDIR/binary.bin"
like "$_BB_STDOUT" "hello world" "strings -n 4 提取长度 >= 4 的字符串"

# -n 10 只提取更长的字符串
bb_run strings -n 10 "$_TEST_TMPDIR/binary.bin"
like "$_BB_STDOUT" "hello world" "strings -n 10 提取 hello world（长度 11）"

# 不存在的文件
bb_run strings "$_TEST_TMPDIR/nonexistent.bin"
cmp_ok "$_BB_EXIT" "!=" "0" "strings 不存在的文件返回非零"

# 无参数从 stdin 读取（传空输入避免挂起）
bb_run_stdin "" strings
is "$_BB_EXIT" "0" "strings 无参数从 stdin 读取不崩溃"

done_testing
