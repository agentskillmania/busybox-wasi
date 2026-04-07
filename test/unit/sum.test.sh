#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 计算 host 端期望值
host_result=$(sum "$file" | awk '{print $1, $2}')
host_cksum=$(echo "$host_result" | awk '{print $1}')
host_blocks=$(echo "$host_result" | awk '{print $2}')

# 基本调用
bb_run sum "$file"
like "$_BB_STDOUT" "^[0-9]+ [0-9]+" "sum 输出包含校验和和块数"

# 校验和匹配 host
bb_run sum "$file"
got_cksum=$(echo "$_BB_STDOUT" | awk '{print $1}')
is "$got_cksum" "$host_cksum" "sum 校验和匹配 host 结果"

# 块数匹配 host
bb_run sum "$file"
got_blocks=$(echo "$_BB_STDOUT" | awk '{print $2}')
is "$got_blocks" "$host_blocks" "sum 块数匹配 host 结果"

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

# 输出格式包含文件名
bb_run sum "$file"
like "$_BB_STDOUT" "test.txt" "sum 输出包含文件名"

done_testing
