#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 相同文件退出码 0 ==========
f1=$(mkfile "same1.txt" "hello world\nline two")
f2=$(mkfile "same2.txt" "hello world\nline two")
bb_run diff "$f1" "$f2"
is "$_BB_EXIT" "0" "diff 相同文件退出码 0"

# ========== 不同文件退出码 1 ==========
f3=$(mkfile "diff1.txt" $'aaa\nbbb\nccc')
f4=$(mkfile "diff2.txt" $'aaa\nxxx\nccc')
bb_run diff "$f3" "$f4"
is "$_BB_EXIT" "1" "diff 不同文件退出码 1"

# ========== 不同文件输出包含差异 ==========
like "$_BB_STDOUT" "xxx" "diff 输出包含差异内容"

# ========== 不存在文件退出码 2 ==========
bb_run diff "$f1" "$TMPDIR/nonexistent.txt"
is "$_BB_EXIT" "2" "diff 文件不存在退出码 2"

# ========== -u 统一格式 ==========
bb_run diff -u "$f3" "$f4"
like "$_BB_STDOUT" "[-+]xxx" "diff -u 统一格式包含加减标记"

# ========== 单行差异 ==========
f5=$(mkfile "one.txt" "only line")
f6=$(mkfile "two.txt" "different line")
bb_run diff "$f5" "$f6"
is "$_BB_EXIT" "1" "diff 单行差异退出码 1"

# ========== 空文件对比 ==========
f7=$(mkfile "empty1.txt" "")
f8=$(mkfile "empty2.txt" "")
bb_run diff "$f7" "$f8"
is "$_BB_EXIT" "0" "diff 两个空文件退出码 0"

# ========== 空文件与非空文件 ==========
f9=$(mkfile "empty3.txt" "")
f10=$(mkfile "nonempty.txt" "content")
bb_run diff "$f9" "$f10"
is "$_BB_EXIT" "1" "diff 空文件与非空文件退出码 1"

# ========== -u 统一格式文件头 ==========
bb_run diff -u "$f3" "$f4"
like "$_BB_STDOUT" "[-+]{3}" "diff -u 包含文件头标记"

# ========== 行数差异 ==========
f11=$(mkfile "short.txt" $'a\nb')
f12=$(mkfile "long.txt" $'a\nb\nc\nd')
bb_run diff "$f11" "$f12"
is "$_BB_EXIT" "1" "diff 行数差异退出码 1"

done_testing
