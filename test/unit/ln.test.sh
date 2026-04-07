#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# 创建硬链接
f1=$(mkfile "ln_target.txt" "link data")
bb_run ln "$f1" "$TMPDIR/ln_hard.txt"
is "$_BB_EXIT" "0" "ln 创建硬链接成功"
bb_run cat "$TMPDIR/ln_hard.txt"
is "$_BB_STDOUT" "link data" "ln 硬链接内容正确"

# 创建符号链接
bb_run ln -s "$f1" "$TMPDIR/ln_sym.txt"
is "$_BB_EXIT" "0" "ln -s 创建符号链接成功"
bb_run cat "$TMPDIR/ln_sym.txt"
is "$_BB_STDOUT" "link data" "ln -s 符号链接内容正确"

# 链接到不存在的目标
bb_run ln -s "$TMPDIR/nonexistent_target" "$TMPDIR/ln_dangling"
is "$_BB_EXIT" "0" "ln -s 创建悬空符号链接成功"

# 硬链接到不存在的目标应失败
bb_run ln "$TMPDIR/nonexistent_target" "$TMPDIR/ln_bad_hard"
cmp_ok "$_BB_EXIT" "!=" "0" "ln 硬链接到不存在的目标返回非零"

# 强制覆盖已存在的链接
mkfile "ln_new_target.txt" "new"
mkfile "ln_existing_link.txt" "old"
bb_run ln -f "$TMPDIR/ln_new_target.txt" "$TMPDIR/ln_existing_link.txt"
is "$_BB_EXIT" "0" "ln -f 强制覆盖已有链接成功"
bb_run cat "$TMPDIR/ln_existing_link.txt"
is "$_BB_STDOUT" "new" "ln -f 覆盖后内容正确"

# 符号链接指向目录
mkdir -p "$TMPDIR/ln_dir"
mkfile "ln_dir/inside.txt" "dir link"
bb_run ln -s "$TMPDIR/ln_dir" "$TMPDIR/ln_dir_link"
is "$_BB_EXIT" "0" "ln -s 创建指向目录的符号链接成功"

done_testing
