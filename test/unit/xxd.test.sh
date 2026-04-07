#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 14

# ========== 基本十六进制转储 ==========
f=$(mkfile "data.txt" "Hello")
bb_run xxd "$f"
is "$_BB_EXIT" "0" "xxd 基本转储成功退出码 0"
# H=48 e=65 l=6c l=6c o=6f
like "$_BB_STDOUT" "4865" "xxd 输出包含 Hello 的十六进制"

# ========== 从 stdin 读取 ==========
bb_run_stdin "AB" xxd
like "$_BB_STDOUT" "4142" "xxd 从 stdin 读取输出 AB 的十六进制"

# ========== -c 8 每行 8 列 ==========
f2=$(mkfile "cols.txt" "ABCDEFGHIJKLMNOP")
bb_run xxd -c 8 "$f2"
count=$(echo "$_BB_STDOUT" | grep -c "^[0-9a-f]*:" || echo "0")
cmp_ok "$count" ">=" "2" "xxd -c 8 每行 8 字节分多行"

# ========== -l 16 限制字节数 ==========
f3=$(mkfile "long.txt" "ABCDEFGHIJKLMNO")
bb_run xxd -l 8 "$f3"
is "$_BB_EXIT" "0" "xxd -l 8 成功退出码 0"
# 只输出前 8 字节
like "$_BB_STDOUT" "41" "xxd -l 8 输出包含 A"
unlike "$_BB_STDOUT" "49" "xxd -l 8 不包含第 9 字节后的 I"

# ========== 空文件 ==========
f4=$(mkfile "empty.txt" "")
bb_run xxd "$f4"
is "$_BB_EXIT" "0" "xxd 空文件成功退出码 0"

# ========== -l 0 不输出数据 ==========
bb_run xxd -l 0 "$f"
is "$_BB_EXIT" "0" "xxd -l 0 成功退出码 0"

# ========== 验证十六进制格式 ==========
bb_run_stdin "abc" xxd
like "$_BB_STDOUT" "6162" "xxd 输出包含 ab 的十六进制 6162"
like "$_BB_STDOUT" "63" "xxd 输出包含 c 的十六进制 63"

# ========== -c 16 默认列数（BusyBox 2 字节一组）==========
bb_run_stdin "0123456789abcdef" xxd
like "$_BB_STDOUT" "3031 3233" "xxd 默认列数输出"

# ========== -l 4 限制 4 字节（BusyBox 2 字节一组）==========
bb_run_stdin "ABCDEFGH" xxd -l 4
like "$_BB_STDOUT" "4142 4344" "xxd -l 4 只输出前 4 字节"

# ========== 地址偏移格式 ==========
bb_run_stdin "test" xxd
like "$_BB_STDOUT" "^[0-9a-f]+:" "xxd 输出以十六进制地址开头"

done_testing
