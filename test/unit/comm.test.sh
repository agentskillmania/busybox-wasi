#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 12

# ========== 准备测试数据（必须已排序）==========
f1=$(mkfile "a.txt" $'apple\nbanana\ncherry')
f2=$(mkfile "b.txt" $'banana\ncherry\ndate')

# ========== 基本比较 ==========
bb_run comm "$f1" "$f2"
like "$_BB_STDOUT" "apple" "comm 第一列显示只在文件1中的行"
like "$_BB_STDOUT" "date" "comm 第三列显示只在文件2中的行"

# ========== -1 隐藏第一列 ==========
bb_run comm -1 "$f1" "$f2"
unlike "$_BB_STDOUT" "^\tapple" "comm -1 隐藏第一列"

# ========== -2 隐藏第二列 ==========
bb_run comm -2 "$f1" "$f2"
like "$_BB_STDOUT" "apple" "comm -2 显示第一列"

# ========== -3 隐藏第三列 ==========
bb_run comm -3 "$f1" "$f2"
unlike "$_BB_STDOUT" "banana" "comm -3 隐藏共有行"

# ========== -12 只显示共有行 ==========
bb_run comm -12 "$f1" "$f2"
like "$_BB_STDOUT" "banana" "comm -12 只显示共有行 banana"
like "$_BB_STDOUT" "cherry" "comm -12 只显示共有行 cherry"

# ========== -23 只显示只在文件1中的行 ==========
bb_run comm -23 "$f1" "$f2"
is "$_BB_STDOUT" "apple" "comm -23 只显示只在文件1中的行"

# ========== -13 只显示只在文件2中的行 ==========
bb_run comm -13 "$f1" "$f2"
is "$_BB_STDOUT" "date" "comm -13 只显示只在文件2中的行"

# ========== 相同文件 ==========
bb_run comm "$f1" "$f1"
unlike "$_BB_STDOUT" "^[^\t]" "comm 相同文件第一列为空"
like "$_BB_STDOUT" "apple" "comm 相同文件包含所有共有行"

# ========== 空文件比较 ==========
f3=$(mkfile "empty.txt" "")
bb_run comm "$f3" "$f3"
is "$_BB_STDOUT" "" "comm 两个空文件比较无输出"

done_testing
