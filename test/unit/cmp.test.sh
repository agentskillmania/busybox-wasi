#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 相同文件退出码 0 ==========
f1=$(mkfile "same1.txt" "identical content")
f2=$(mkfile "same2.txt" "identical content")
bb_run cmp "$f1" "$f2"
is "$_BB_EXIT" "0" "cmp 相同文件退出码 0"

# ========== 不同文件退出码 1 ==========
f3=$(mkfile "a.txt" "hello world")
f4=$(mkfile "b.txt" "hello earth")
bb_run cmp "$f3" "$f4"
is "$_BB_EXIT" "1" "cmp 不同文件退出码 1"

# ========== 不同文件输出差异位置 ==========
like "$_BB_STDOUT" "differ" "cmp 报告文件不同"

# ========== 不存在文件退出码 2 ==========
bb_run cmp "$f1" "$TMPDIR/no_such.txt"
is "$_BB_EXIT" "2" "cmp 文件不存在退出码 2"

# ========== -l 详细输出 ==========
f5=$(mkfile "x.txt" "abc")
f6=$(mkfile "y.txt" "axc")
bb_run cmp -l "$f5" "$f6"
is "$_BB_EXIT" "1" "cmp -l 不同退出码 1"
like "$_BB_STDOUT" "[0-9]" "cmp -l 输出字节偏移"

# ========== 完全相同无输出 ==========
f7=$(mkfile "s1.txt" "same")
f8=$(mkfile "s2.txt" "same")
bb_run cmp "$f7" "$f8"
is "$_BB_STDOUT" "" "cmp 相同文件无输出"

# ========== 空文件比较 ==========
f9=$(mkfile "e1.txt" "")
f10=$(mkfile "e2.txt" "")
bb_run cmp "$f9" "$f10"
is "$_BB_EXIT" "0" "cmp 两个空文件退出码 0"

# ========== 长文件与短文件 ==========
f11=$(mkfile "long.txt" "abcde")
f12=$(mkfile "short.txt" "abc")
bb_run cmp "$f11" "$f12"
is "$_BB_EXIT" "1" "cmp 长短文件不同退出码 1"

# ========== 首字节不同 ==========
f13=$(mkfile "p1.txt" "Xello")
f14=$(mkfile "p2.txt" "Hello")
bb_run cmp "$f13" "$f14"
like "$_BB_STDOUT" "byte 1" "cmp 首字节不同报告位置"

done_testing
