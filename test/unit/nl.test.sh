#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 11

# ========== 基本行号 ==========
f=$(mkfile "data.txt" $'line1\nline2\nline3')
bb_run nl "$f"
like "$_BB_STDOUT" "1.*line1" "nl 基本行号标注"
like "$_BB_STDOUT" "3.*line3" "nl 第三行标注"

# ========== 从 stdin ==========
bb_run_stdin $'a\nb\nc' nl
like "$_BB_STDOUT" "1.*a" "nl 从 stdin 读取标注行号"

# ========== -b a 所有行编号 ==========
f2=$(mkfile "empty_lines.txt" $'a\n\nb')
bb_run nl -b a "$f2"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "3" "nl -b a 空行也编号"

# ========== -s 自定义分隔符 ==========
bb_run_stdin $'x\ny' nl -s "> "
like "$_BB_STDOUT" "> x" "nl -s 自定义分隔符"

# ========== 空输入 ==========
bb_run_stdin "" nl
is "$_BB_STDOUT" "" "nl 空输入无输出"

# ========== 单行 ==========
bb_run_stdin "only" nl
like "$_BB_STDOUT" "1" "nl 单行标注行号 1"

# ========== -n rz 右对齐补零 ==========
bb_run_stdin $'a\nb\nc\nd\ne\nf\ng\nh\ni' nl -n rz
like "$_BB_STDOUT" "000001" "nl -n rz 右对齐补零"

# ========== -n ln 左对齐 ==========
bb_run_stdin "hello" nl -n ln
like "$_BB_STDOUT" "^1 " "nl -n ln 左对齐"

# ========== 多行连续编号 ==========
bb_run_stdin $'first\nsecond\nthird\nfourth\nfifth' nl
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "5" "nl 多行连续编号共 5 行"

# ========== -v 起始编号 ==========
bb_run_stdin $'a\nb\nc' nl -v 10
like "$_BB_STDOUT" "10" "nl -v 10 起始编号为 10"

done_testing
