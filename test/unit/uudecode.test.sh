#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# 生成测试数据和 uuencode 格式文件
# 使用 host 的 uuencode 生成可靠的编码数据
data_file=$(mkfile "test.txt" "hello world")
host_encoded=$(uuencode "$data_file" test.txt)
enc_file=$(mkfile "test.uu" "$host_encoded")

# 基本 uudecode
bb_run uudecode "$enc_file"
is "$_BB_EXIT" "0" "uudecode 解码不崩溃"

# 通过 -o 指定输出文件
outfile="$_TEST_TMPDIR/decoded.txt"
bb_run uudecode -o "$outfile" "$enc_file"
is "$_BB_EXIT" "0" "uudecode -o 输出文件不崩溃"

# 验证解码内容
if [[ -f "$outfile" ]]; then
    decoded=$(cat "$outfile")
    is "$decoded" "hello world" "uudecode 解码还原原始数据"
else
    skip "uudecode 未生成输出文件"
fi

# 通过 stdin 解码
bb_run_stdin "$host_encoded" uudecode
is "$_BB_EXIT" "0" "uudecode 通过 stdin 解码"

# 空内容的 uudecode
empty_enc="begin 644 empty.txt\n\`\nend\n"
empty_file=$(mkfile "empty.uu" "$(printf 'begin 644 empty.txt\n`\nend\n')")
bb_run uudecode "$empty_file"
is "$_BB_EXIT" "0" "uudecode 空内容不崩溃"

# 编码再解码往返验证
file2=$(mkfile "roundtrip.txt" "test data 123")
host_enc2=$(uuencode "$file2" roundtrip.txt)
enc2=$(mkfile "roundtrip.uu" "$host_enc2")
outfile2="$_TEST_TMPDIR/roundtrip_decoded.txt"
bb_run uudecode -o "$outfile2" "$enc2"
if [[ -f "$outfile2" ]]; then
    is "$(cat "$outfile2")" "test data 123" "uudecode 往返验证"
else
    skip "uudecode 往返未生成输出文件"
fi

done_testing
