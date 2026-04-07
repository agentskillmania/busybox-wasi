#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 基本 uuencode 编码
bb_run uuencode "$file" test.txt
is "$_BB_EXIT" "0" "uuencode 编码不崩溃"

# 输出以 begin 行开头
bb_run uuencode "$file" test.txt
like "$_BB_STDOUT" "^begin [0-7]+" "uuencode 输出以 begin 行开头"

# 输出以 end 行结尾
bb_run uuencode "$file" test.txt
like "$_BB_STDOUT" "end$" "uuencode 输出以 end 行结尾"

# 通过 stdin 编码
bb_run_stdin "hello world" uuencode stdin.txt
is "$_BB_EXIT" "0" "uuencode 通过 stdin 编码"

# 空文件编码
empty=$(mkfile "empty.txt" "")
bb_run uuencode "$empty" empty.txt
is "$_BB_EXIT" "0" "uuencode 空文件不崩溃"

# 编码输出包含编码数据行
bb_run uuencode "$file" test.txt
encoded_lines=$(echo "$_BB_STDOUT" | wc -l)
cmp_ok "$encoded_lines" ">=" "3" "uuencode 输出至少 3 行（begin + 数据 + end）"

done_testing
