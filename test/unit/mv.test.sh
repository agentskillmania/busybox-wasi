#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 基本移动/重命名文件
f1=$(mkfile "mv_src.txt" "move me")
bb_run mv "$f1" "$TMPDIR/mv_dst.txt"
is "$_BB_EXIT" "0" "mv 移动文件成功"
bb_run cat "$TMPDIR/mv_dst.txt"
is "$_BB_STDOUT" "move me" "mv 移动后内容正确"

# 源文件不应再存在
bb_run cat "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "mv 移动后源文件不存在"

# 移动文件到目录
mkdir -p "$TMPDIR/mvdir"
f2=$(mkfile "to_mvdir.txt" "into dir")
bb_run mv "$f2" "$TMPDIR/mvdir/"
is "$_BB_EXIT" "0" "mv 移动文件到目录成功"
bb_run cat "$TMPDIR/mvdir/to_mvdir.txt"
is "$_BB_STDOUT" "into dir" "mv 移动到目录后内容正确"

# 多个文件移动到目录
mkfile "multi1.txt" "m1"
mkfile "multi2.txt" "m2"
mkdir -p "$TMPDIR/multi_dst"
bb_run mv "$TMPDIR/multi1.txt" "$TMPDIR/multi2.txt" "$TMPDIR/multi_dst/"
is "$_BB_EXIT" "0" "mv 移动多个文件到目录成功"
bb_run cat "$TMPDIR/multi_dst/multi1.txt"
is "$_BB_STDOUT" "m1" "mv 多文件移动后第一个文件内容正确"

# 源文件不存在
bb_run mv "$TMPDIR/nonexistent_mv.txt" "$TMPDIR/nowhere.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "mv 源文件不存在返回非零"

# 移动到不存在的嵌套路径
mkfile "deep.txt" "deep"
bb_run mv "$TMPDIR/deep.txt" "$TMPDIR/no/such/dir/deep.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "mv 目标目录不存在返回非零"

done_testing
