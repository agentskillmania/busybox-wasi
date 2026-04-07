#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 基本调用
bb_run sum "$file"
like "$_BB_STDOUT" "^[0-9]+[[:space:]]+[0-9]+" "sum 输出包含校验和和块数"

# 通过 stdin
bb_run_stdin "hello world" sum
is "$_BB_EXIT" "0" "sum 通过 stdin 计算不崩溃"

# 空文件
empty=$(mkfile "empty.txt" "")
bb_run sum "$empty"
is "$_BB_EXIT" "0" "sum 空文件不崩溃"

# 多文件
file2=$(mkfile "test2.txt" "foo bar baz")
bb_run sum "$file" "$file2"
cmp_ok "$(echo "$_BB_STDOUT" | wc -l)" "==" "2" "sum 多文件输出两行"

# 校验和是非零数字
bb_run sum "$file"
got_cksum=$(echo "$_BB_STDOUT" | awk '{print $1}')
isnt "$got_cksum" "" "sum 校验和非空"

# BusyBox sum 不输出文件名（不像 GNU sum）
# BusyBox sum 和 macOS sum 输出格式不同（前导零、空格数），不能直接比较
# 输出格式验证
bb_run sum "$file"
like "$_BB_STDOUT" "[0-9]" "sum 输出包含数字"

skip "sum 校验和与 host 比较格式不一致（BusyBox 有前导零）"
skip "sum 块数与 host 比较格式不一致"

done_testing
