#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# 已知编码值：base64("hello world") = "aGVsbG8gd29ybGQ="
known_encoded="aGVsbG8gd29ybGQ="
# 已知编码值：base64("Hello") = "SGVsbG8="
known_hello_encoded="SGVsbG8="

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 编码
bb_run base64 "$file"
is "$_BB_EXIT" "0" "base64 编码不崩溃"

# 获取编码结果
encoded="$_BB_STDOUT"

# 编码结果匹配已知值
is "$(echo "$encoded" | tr -d '\n')" "$known_encoded" "base64 编码匹配已知值"

# 解码往返
enc_file=$(mkfile "encoded.b64" "$encoded")
bb_run base64 -d "$enc_file"
is "$_BB_STDOUT" "hello world" "base64 解码还原原始数据"

# 通过 stdin 编码
bb_run_stdin "hello world" base64
is "$(echo "$_BB_STDOUT" | tr -d '\n')" "$known_encoded" "base64 通过 stdin 编码"

# 空输入
empty=$(mkfile "empty.txt" "")
bb_run base64 "$empty"
is "$_BB_EXIT" "0" "base64 空文件不崩溃"

# 解码空输入
empty_enc=$(mkfile "empty_enc.b64" "")
bb_run base64 -d "$empty_enc"
is "$_BB_EXIT" "0" "base64 解码空文件不崩溃"

# 已知编码值验证
known_file=$(mkfile "known.txt" "Hello")
bb_run base64 "$known_file"
is "$(echo "$_BB_STDOUT" | tr -d '\n')" "$known_hello_encoded" "base64 已知值编码正确"

# -w 0 单行输出
bb_run base64 -w 0 "$file"
is "$_BB_EXIT" "0" "base64 -w 0 不崩溃"

# 编码输出只含 base64 字符
bb_run base64 "$file"
like "$_BB_STDOUT" "^[A-Za-z0-9+/=\n]*$" "base64 编码输出只含有效字符"

done_testing
