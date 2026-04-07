#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 基本 head
bb_run_stdin $'1\n2\n3\n4\n5' head -n 3
is "$_BB_STDOUT" $'1\n2\n3' "head -n 前 3 行"

# 默认 10 行
input=""
for i in $(seq 1 15); do input="${input}line$i"$'\n'; done
bb_run_stdin "$input" head
# 输出应为 10 行
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "10" "head 默认输出 10 行"

# -c 字节数
bb_run_stdin "hello world" head -c 5
is "$_BB_STDOUT" "hello" "head -c 前 5 字节"

# 文件输入
f=$(mkfile "data.txt" $'a\nb\nc')
bb_run head -n 2 "$f"
is "$_BB_STDOUT" $'a\nb' "head 从文件读取"

# 行数超过文件
bb_run_stdin $'a\nb' head -n 100
is "$_BB_STDOUT" $'a\nb' "head 行数超过文件行数"

# -n 0
bb_run_stdin $'a\nb\nc' head -n 0
is "$_BB_STDOUT" "" "head -n 0 无输出"

# 空输入
bb_run_stdin "" head
is "$_BB_STDOUT" "" "head 空输入"

# 负数行（除最后 N 行外全部）
bb_run_stdin $'1\n2\n3\n4\n5' head -n -2
is "$_BB_STDOUT" $'1\n2\n3' "head -n -2 除最后 2 行"

done_testing
