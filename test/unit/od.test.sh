#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 12

# ========== 基本八进制转储 ==========
f=$(mkfile "data.txt" "ABC")
bb_run od "$f"
is "$_BB_EXIT" "0" "od 基本转储成功退出码 0"
like "$_BB_STDOUT" "[0-7]+" "od 输出包含八进制数值"

# ========== -A x 十六进制地址 ==========
bb_run od -A x "$f"
like "$_BB_STDOUT" "[0-9a-f]+" "od -A x 十六进制地址"

# ========== -A n 无地址 ==========
bb_run od -A n "$f"
unlike "$_BB_STDOUT" "^[0-7]+" "od -A n 不显示地址前缀"

# ========== -t x1 十六进制字节 ==========
bb_run od -t x1 "$f"
# A=41 B=42 C=43
like "$_BB_STDOUT" "41" "od -t x1 显示 A 的十六进制 41"
like "$_BB_STDOUT" "42" "od -t x1 显示 B 的十六进制 42"

# ========== -c 字符显示 ==========
bb_run od -c "$f"
like "$_BB_STDOUT" "A" "od -c 显示字符 A"
like "$_BB_STDOUT" "B" "od -c 显示字符 B"

# ========== 从 stdin 读取 ==========
bb_run_stdin "Hi" od
is "$_BB_EXIT" "0" "od 从 stdin 读取成功"

# ========== 空文件 ==========
f2=$(mkfile "empty.txt" "")
bb_run od "$f2"
is "$_BB_EXIT" "0" "od 空文件成功退出码 0"

# ========== -t o1 八进制字节 ==========
bb_run od -t o1 "$f"
like "$_BB_STDOUT" "101" "od -t o1 显示 A 的八进制 101"

# ========== 组合格式 ==========
bb_run od -A x -t x1 "$f"
like "$_BB_STDOUT" "41" "od -A x -t x1 组合格式"

done_testing
