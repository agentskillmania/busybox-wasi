#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 基本行反转 ==========
bb_run_stdin "hello" rev
is "$_BB_STDOUT" "olleh" "rev 反转字符串"

# ========== 多行 ==========
bb_run_stdin $'abc\ndef' rev
is "$_BB_STDOUT" $'cba\nfed' "rev 多行每行反转"

# ========== 从文件读取 ==========
f=$(mkfile "data.txt" $'world\nhello')
bb_run rev "$f"
is "$_BB_STDOUT" $'dlrow\nolleh' "rev 从文件读取反转"

# ========== 空输入 ==========
bb_run_stdin "" rev
is "$_BB_STDOUT" "" "rev 空输入无输出"

# ========== 回文 ==========
bb_run_stdin "madam" rev
is "$_BB_STDOUT" "madam" "rev 回文字符串反转后不变"

# ========== 单字符 ==========
bb_run_stdin "x" rev
is "$_BB_STDOUT" "x" "rev 单字符不变"

# ========== 包含空格 ==========
bb_run_stdin "ab cd" rev
is "$_BB_STDOUT" "dc ba" "rev 包含空格整行反转"

# ========== 包含数字 ==========
bb_run_stdin "12345" rev
is "$_BB_STDOUT" "54321" "rev 数字反转"

# ========== 包含标点 ==========
bb_run_stdin "a,b.c!" rev
is "$_BB_STDOUT" "!c.b,a" "rev 标点符号也反转"

# ========== 长行反转 ==========
long=""
for i in $(seq 1 50); do long="${long}x"; done
bb_run_stdin "$long" rev
rev_len=$(echo "$_BB_STDOUT" | tr -d '\n' | wc -c | tr -d ' ')
is "$rev_len" "50" "rev 长行反转长度不变"

done_testing
