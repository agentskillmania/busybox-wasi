#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 删除文件
f1=$(mkfile "unlink_me.txt" "unlink data")
bb_run unlink "$f1"
is "$_BB_EXIT" "0" "unlink 删除文件成功"

# 文件应已不存在
bb_run cat "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "unlink 删除后文件不存在"

# 删除不存在的文件应失败
bb_run unlink "$TMPDIR/no_such_unlink.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "unlink 删除不存在的文件返回非零"

# 删除空文件
f2=$(mkfile "unlink_empty.txt" "")
bb_run unlink "$f2"
is "$_BB_EXIT" "0" "unlink 删除空文件成功"

# 删除目录应失败（unlink 只能删除文件）
mkdir -p "$TMPDIR/unlink_dir"
bb_run unlink "$TMPDIR/unlink_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "unlink 不能删除目录"

# 无参数应失败
bb_run unlink
cmp_ok "$_BB_EXIT" "!=" "0" "unlink 无参数返回非零"

done_testing
