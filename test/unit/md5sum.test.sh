#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 计算 host 端期望值
expected=$(md5sum "$file" | awk '{print $1}')

# 基本文件哈希
bb_run md5sum "$file"
like "$_BB_STDOUT" "^${expected}" "md5sum 文件哈希匹配 host 结果"

# 通过 stdin 计算哈希
bb_run_stdin "hello world" md5sum
like "$_BB_STDOUT" "${expected}" "md5sum 通过 stdin 计算哈希"

# 输出格式: 哈希值 + 两个空格 + 文件名
bb_run md5sum "$file"
like "$_BB_STDOUT" "^[0-9a-f]{32}  " "md5sum 输出格式正确（32位十六进制 + 两空格）"

# -c 校验模式：正确校验和（用绝对路径，WASI CWD 是 /）
cksum_file=$(mkfile "md5.check" "${expected}  ${file}")
bb_run md5sum -c "$cksum_file"
like "$_BB_STDOUT" "OK" "md5sum -c 校验正确的哈希"

# -c 校验模式：错误校验和
bad_file=$(mkfile "md5bad.check" "00000000000000000000000000000000  ${file}")
bb_run md5sum -c "$bad_file"
cmp_ok "$_BB_EXIT" "!=" "0" "md5sum -c 错误哈希返回非零"

# 空文件的哈希
empty=$(mkfile "empty.txt" "")
bb_run md5sum "$empty"
is "$_BB_EXIT" "0" "md5sum 空文件不崩溃"

# 多文件
file2=$(mkfile "test2.txt" "foo")
bb_run md5sum "$file" "$file2"
cmp_ok "$(echo "$_BB_STDOUT" | wc -l)" "==" "2" "md5sum 多文件输出两行"

# 验证哈希值长度
bb_run md5sum "$file"
hash=$(echo "$_BB_STDOUT" | awk '{print $1}')
is "${#hash}" "32" "md5sum 哈希值长度为 32"

done_testing
