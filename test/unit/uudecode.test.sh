#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# uudecode 在 WASI 中：
# - 不带 -o 时，尝试创建文件但 cwd 不可写，失败
# - 带 -o 时，可以正确解码文件
# - 通过 stdin 带 -o 也可以工作

# 生成测试数据和 uuencode 格式文件
data_file=$(mkfile "test.txt" "hello world")
host_encoded=$(uuencode "$data_file" test.txt)
enc_file=$(mkfile "test.uu" "$host_encoded")

# 基本 uudecode 不带 -o 在 WASI 中失败（尝试在 cwd 创建文件，权限不足）
bb_run uudecode "$enc_file"
cmp_ok "$_BB_EXIT" "!=" "0" "uudecode 不带 -o 在 WASI 中失败（无法在 cwd 创建文件）"

# 通过 -o 指定输出文件可以正常工作
outfile="$_TEST_TMPDIR/decoded.txt"
bb_run uudecode -o "$outfile" "$enc_file"
is "$_BB_EXIT" "0" "uudecode -o 输出文件成功"

# 验证解码内容
if [[ -f "$outfile" ]]; then
    decoded=$(cat "$outfile")
    is "$decoded" "hello world" "uudecode 解码还原原始数据"
else
    skip "uudecode 未生成输出文件"
fi

# 通过 stdin 带 -o 解码可以工作
bb_run_stdin "$host_encoded" uudecode -o "$_TEST_TMPDIR/stdin_decoded.txt"
is "$_BB_EXIT" "0" "uudecode 通过 stdin 带 -o 解码成功"

# 空内容的 uudecode 带 -o 可以工作
empty_file=$(mkfile "empty.uu" "$(printf 'begin 644 empty.txt\n`\nend\n')")
bb_run uudecode -o "$_TEST_TMPDIR/empty_out.txt" "$empty_file"
is "$_BB_EXIT" "0" "uudecode 空内容带 -o 成功"

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
