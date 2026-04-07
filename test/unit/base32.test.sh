#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# 已知编码值：base32("hello world") = "NBSWY3DPEB3W64TMMQ======"
known_encoded="NBSWY3DPEB3W64TMMQ======"

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 编码
bb_run base32 "$file"
is "$_BB_EXIT" "0" "base32 编码不崩溃"

# 获取编码结果
encoded="$_BB_STDOUT"

# 编码结果匹配已知值
is "$(echo "$encoded" | tr -d '\n')" "$known_encoded" "base32 编码匹配已知值"

# 解码往返
enc_file=$(mkfile "encoded.b32" "$encoded")
bb_run base32 -d "$enc_file"
is "$_BB_STDOUT" "hello world" "base32 解码还原原始数据"

# 通过 stdin 编码
bb_run_stdin "hello world" base32
is "$(echo "$_BB_STDOUT" | tr -d '\n')" "$known_encoded" "base32 通过 stdin 编码"

# 空输入
empty=$(mkfile "empty.txt" "")
bb_run base32 "$empty"
is "$_BB_EXIT" "0" "base32 空文件不崩溃"

# 解码空输入
empty_enc=$(mkfile "empty_enc.b32" "")
bb_run base32 -d "$empty_enc"
is "$_BB_EXIT" "0" "base32 解码空文件不崩溃"

# 编码输出只含 base32 字符
bb_run base32 "$file"
like "$_BB_STDOUT" "^[A-Z2-7=\n]*$" "base32 编码输出只含有效字符"

done_testing
