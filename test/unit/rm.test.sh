#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 删除文件
f1=$(mkfile "rm_me.txt" "bye")
bb_run rm "$f1"
is "$_BB_EXIT" "0" "rm 删除文件成功"

# 文件应已不存在
bb_run cat "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "rm 删除后文件不存在"

# -f 强制删除不存在的文件（不报错）
bb_run rm -f "$TMPDIR/no_such_file.txt"
is "$_BB_EXIT" "0" "rm -f 删除不存在的文件返回成功"

# 不带 -f 删除不存在的文件（应报错）
bb_run rm "$TMPDIR/also_no_such.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "rm 删除不存在的文件返回非零"

# -r 递归删除目录
mkdir -p "$TMPDIR/rm_dir/sub"
mkfile "rm_dir/a.txt" "a"
mkfile "rm_dir/sub/b.txt" "b"
bb_run rm -r "$TMPDIR/rm_dir"
is "$_BB_EXIT" "0" "rm -r 递归删除目录成功"

# 目录应已不存在
bb_run ls "$TMPDIR/rm_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "rm -r 删除后目录不存在"

# 删除目录（不带 -r 应失败）
mkdir -p "$TMPDIR/rm_nondir"
bb_run rm "$TMPDIR/rm_nondir"
cmp_ok "$_BB_EXIT" "!=" "0" "rm 不带 -r 删除目录返回非零"

# -rf 强制递归删除
mkdir -p "$TMPDIR/rm_rf_dir"
mkfile "rm_rf_dir/file.txt" "content"
bb_run rm -rf "$TMPDIR/rm_rf_dir"
is "$_BB_EXIT" "0" "rm -rf 强制递归删除成功"

# -rf 删除不存在的目录不报错
bb_run rm -rf "$TMPDIR/ghost_dir"
is "$_BB_EXIT" "0" "rm -rf 删除不存在的目录不报错"

done_testing
