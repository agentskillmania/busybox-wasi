#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 计算 host 端期望值
expected=$(shasum -a 1 "$file" | awk '{print $1}')

# 基本文件哈希
bb_run sha1sum "$file"
like "$_BB_STDOUT" "^${expected}" "sha1sum 文件哈希匹配 host 结果"

# 通过 stdin 计算哈希
bb_run_stdin "hello world" sha1sum
like "$_BB_STDOUT" "${expected}" "sha1sum 通过 stdin 计算哈希"

# 输出格式: 哈希值 + 两个空格 + 文件名
bb_run sha1sum "$file"
like "$_BB_STDOUT" "^[0-9a-f]{40}  " "sha1sum 输出格式正确（40位十六进制 + 两空格）"

# -c 校验模式：正确校验和
cksum_file=$(mkfile "sha1.check" "${expected}  test.txt")
bb_run sha1sum -c "$cksum_file"
like "$_BB_STDOUT" "OK" "sha1sum -c 校验正确的哈希"

# -c 校验模式：错误校验和
bad_file=$(mkfile "sha1bad.check" "0000000000000000000000000000000000000000  test.txt")
bb_run sha1sum -c "$bad_file"
cmp_ok "$_BB_EXIT" "!=" "0" "sha1sum -c 错误哈希返回非零"

# 空文件
empty=$(mkfile "empty.txt" "")
bb_run sha1sum "$empty"
is "$_BB_EXIT" "0" "sha1sum 空文件不崩溃"

# 多文件
file2=$(mkfile "test2.txt" "foo")
bb_run sha1sum "$file" "$file2"
cmp_ok "$(echo "$_BB_STDOUT" | wc -l)" "==" "2" "sha1sum 多文件输出两行"

# 哈希值长度
bb_run sha1sum "$file"
hash=$(echo "$_BB_STDOUT" | awk '{print $1}')
is "${#hash}" "40" "sha1sum 哈希值长度为 40"

done_testing
