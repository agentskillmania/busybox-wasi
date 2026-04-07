#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 基本文件复制
f1=$(mkfile "src.txt" "hello cp")
bb_run cp "$f1" "$TMPDIR/dst.txt"
is "$_BB_EXIT" "0" "cp 复制文件成功"
bb_run cat "$TMPDIR/dst.txt"
is "$_BB_STDOUT" "hello cp" "cp 复制内容正确"

# 覆盖已有文件
mkfile "overwrite.txt" "old"
mkfile "new.txt" "new content"
bb_run cp "$TMPDIR/new.txt" "$TMPDIR/overwrite.txt"
is "$_BB_EXIT" "0" "cp 覆盖已有文件成功"
bb_run cat "$TMPDIR/overwrite.txt"
is "$_BB_STDOUT" "new content" "cp 覆盖后内容正确"

# 复制到目录
mkdir -p "$TMPDIR/cpdir"
mkfile "to_dir.txt" "dir content"
bb_run cp "$TMPDIR/to_dir.txt" "$TMPDIR/cpdir/"
is "$_BB_EXIT" "0" "cp 复制文件到目录成功"
bb_run cat "$TMPDIR/cpdir/to_dir.txt"
is "$_BB_STDOUT" "dir content" "cp 复制到目录后内容正确"

# 源文件不存在
bb_run cp "$TMPDIR/nonexistent_src.txt" "$TMPDIR/dst2.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "cp 源文件不存在返回非零"

# 递归复制目录
mkdir -p "$TMPDIR/rc_src/sub"
mkfile "rc_src/a.txt" "a"
mkfile "rc_src/sub/b.txt" "b"
bb_run cp -r "$TMPDIR/rc_src" "$TMPDIR/rc_dst"
is "$_BB_EXIT" "0" "cp -r 递归复制目录成功"
bb_run cat "$TMPDIR/rc_dst/a.txt"
is "$_BB_STDOUT" "a" "cp -r 递归复制后子文件内容正确"

# 目标路径无写权限（在 WASI 中测试基本报错）
bb_run cp "$TMPDIR/nonexistent" "$TMPDIR/also_nonexistent"
cmp_ok "$_BB_EXIT" "!=" "0" "cp 复制不存在的源文件报错"

done_testing
