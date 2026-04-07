#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 计算 host 端期望值
expected=$(shasum -a 512 "$file" | awk '{print $1}')

# 基本文件哈希
bb_run sha512sum "$file"
like "$_BB_STDOUT" "^${expected}" "sha512sum 文件哈希匹配 host 结果"

# 通过 stdin 计算哈希
bb_run_stdin "hello world" sha512sum
like "$_BB_STDOUT" "${expected}" "sha512sum 通过 stdin 计算哈希"

# 输出格式: 哈希值 + 两个空格 + 文件名
bb_run sha512sum "$file"
like "$_BB_STDOUT" "^[0-9a-f]{128}  " "sha512sum 输出格式正确（128位十六进制 + 两空格）"

# -c 校验模式：正确校验和
cksum_file=$(mkfile "sha512.check" "${expected}  ${file}")
bb_run sha512sum -c "$cksum_file"
like "$_BB_STDOUT" "OK" "sha512sum -c 校验正确的哈希"

# -c 校验模式：错误校验和
bad_file=$(mkfile "sha512bad.check" "$(printf '%0128s' | tr ' ' '0')  ${file}")
bb_run sha512sum -c "$bad_file"
cmp_ok "$_BB_EXIT" "!=" "0" "sha512sum -c 错误哈希返回非零"

# 空文件
empty=$(mkfile "empty.txt" "")
bb_run sha512sum "$empty"
is "$_BB_EXIT" "0" "sha512sum 空文件不崩溃"

# 多文件
file2=$(mkfile "test2.txt" "foo")
bb_run sha512sum "$file" "$file2"
cmp_ok "$(echo "$_BB_STDOUT" | wc -l)" "==" "2" "sha512sum 多文件输出两行"

# 哈希值长度
bb_run sha512sum "$file"
hash=$(echo "$_BB_STDOUT" | awk '{print $1}')
is "${#hash}" "128" "sha512sum 哈希值长度为 128"

done_testing
