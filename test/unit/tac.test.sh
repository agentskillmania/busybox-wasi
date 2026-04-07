#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 基本反转 ==========
bb_run_stdin $'line1\nline2\nline3' tac
is "$_BB_STDOUT" $'line3\nline2\nline1' "tac 反转行顺序"

# ========== 两行 ==========
bb_run_stdin $'first\nlast' tac
is "$_BB_STDOUT" $'last\nfirst' "tac 两行反转"

# ========== 单行 ==========
bb_run_stdin "only line" tac
is "$_BB_STDOUT" "only line" "tac 单行不变"

# ========== 从文件读取 ==========
f=$(mkfile "data.txt" $'a\nb\nc\nd\ne')
bb_run tac "$f"
is "$_BB_STDOUT" $'e\nd\nc\nb\na' "tac 从文件读取反转"

# ========== 空输入 ==========
bb_run_stdin "" tac
is "$_BB_STDOUT" "" "tac 空输入无输出"

# ========== 多行 stdin ==========
bb_run_stdin $'1\n2\n3\n4\n5\n6\n7\n8\n9\n10' tac
first_line=$(echo "$_BB_STDOUT" | head -n 1)
is "$first_line" "10" "tac 多行 stdin 首行为 10"

# ========== 行内空格不受影响 ==========
bb_run_stdin $'hello world\nfoo bar' tac
is "$_BB_STDOUT" $'foo bar\nhello world' "tac 行内空格不受影响"

# ========== 重复行 ==========
bb_run_stdin $'a\na\nb' tac
is "$_BB_STDOUT" $'b\na\na' "tac 重复行反转"

# ========== -s 分隔符 ==========
bb_run_stdin $'a\nb\nc' tac -s '\n'
is "$_BB_EXIT" "0" "tac -s 指定分隔符成功"

# ========== 长内容反转 ==========
input=""
for i in $(seq 1 20); do input="${input}line$i"$'\n'; done
bb_run_stdin "$input" tac
last_line=$(echo "$_BB_STDOUT" | head -n 1)
is "$last_line" "line20" "tac 长内容反转首行为最后一行"

done_testing
