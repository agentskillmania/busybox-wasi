#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 计算 host 端期望值
host_result=$(cksum "$file" | awk '{print $1, $2}')
host_crc=$(echo "$host_result" | awk '{print $1}')
host_bytes=$(echo "$host_result" | awk '{print $2}')

# 基本文件校验
bb_run cksum "$file"
like "$_BB_STDOUT" "^[0-9]+ [0-9]+" "cksum 输出包含 CRC 和字节数"

# CRC 值匹配 host
bb_run cksum "$file"
got_crc=$(echo "$_BB_STDOUT" | awk '{print $1}')
is "$got_crc" "$host_crc" "cksum CRC 值匹配 host 结果"

# 字节数匹配 host
bb_run cksum "$file"
got_bytes=$(echo "$_BB_STDOUT" | awk '{print $2}')
is "$got_bytes" "$host_bytes" "cksum 字节数匹配 host 结果"

# 通过 stdin 计算
bb_run_stdin "hello world" cksum
like "$_BB_STDOUT" "^[0-9]+ [0-9]+" "cksum 通过 stdin 计算"

# 输出格式: CRC 字节数 文件名
bb_run cksum "$file"
like "$_BB_STDOUT" "^[0-9]+ [0-9]+ test.txt" "cksum 输出包含文件名"

# 空文件
empty=$(mkfile "empty.txt" "")
bb_run cksum "$empty"
is "$_BB_EXIT" "0" "cksum 空文件不崩溃"

# 多文件
file2=$(mkfile "test2.txt" "foo")
bb_run cksum "$file" "$file2"
cmp_ok "$(echo "$_BB_STDOUT" | wc -l)" "==" "2" "cksum 多文件输出两行"

# 不同内容产生不同 CRC
file3=$(mkfile "test3.txt" "different content")
bb_run cksum "$file3"
crc3=$(echo "$_BB_STDOUT" | awk '{print $1}')
isnt "$crc3" "$host_crc" "cksum 不同内容产生不同 CRC"

done_testing
