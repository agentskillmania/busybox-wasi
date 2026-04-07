#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 创建测试目录结构
mkdir -p "$TMPDIR/subdir"
mkfile "file1.txt" "hello"
mkfile "file2.txt" "world"
mkfile "subdir/nested.txt" "nested"

# 基本 ls
bb_run ls "$TMPDIR"
like "$_BB_STDOUT" "file1.txt" "ls 列出文件"
like "$_BB_STDOUT" "file2.txt" "ls 列出第二个文件"

# -a 包含隐藏文件
mkfile ".hidden" "hidden"
bb_run ls -a "$TMPDIR"
like "$_BB_STDOUT" "\.hidden" "ls -a 显示隐藏文件"

# -l 长格式
bb_run ls -l "$TMPDIR"
like "$_BB_STDOUT" "file1.txt" "ls -l 长格式"

# -R 递归
bb_run ls -R "$TMPDIR"
like "$_BB_STDOUT" "nested.txt" "ls -R 递归列出子目录"

# 不存在的目录
bb_run ls "$TMPDIR/nope"
cmp_ok "$_BB_EXIT" "!=" "0" "ls 不存在的目录报错"

# 空目录
mkdir "$TMPDIR/emptydir"
bb_run ls "$TMPDIR/emptydir"
is "$_BB_STDOUT" "" "ls 空目录无输出"

# 单文件
bb_run ls "$TMPDIR/file1.txt"
like "$_BB_STDOUT" "file1" "ls 单文件"

done_testing
