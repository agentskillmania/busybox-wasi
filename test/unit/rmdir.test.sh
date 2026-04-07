#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# 删除空目录
mkdir -p "$TMPDIR/empty_dir"
bb_run rmdir "$TMPDIR/empty_dir"
is "$_BB_EXIT" "0" "rmdir 删除空目录成功"
cmp_ok "$(test -d "$TMPDIR/empty_dir" && echo 1 || echo 0)" "==" "0" "rmdir 删除后目录不存在"

# 删除非空目录应失败
mkdir -p "$TMPDIR/nonempty"
mkfile "nonempty/file.txt" "content"
bb_run rmdir "$TMPDIR/nonempty"
cmp_ok "$_BB_EXIT" "!=" "0" "rmdir 删除非空目录返回非零"

# 删除不存在的目录应失败
bb_run rmdir "$TMPDIR/ghost_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "rmdir 删除不存在的目录返回非零"

# 删除文件（非目录）应失败
f1=$(mkfile "not_a_dir.txt" "data")
bb_run rmdir "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "rmdir 对文件返回非零"

# 删除多层空目录（先删子目录再删父目录）
mkdir -p "$TMPDIR/parent/child"
bb_run rmdir "$TMPDIR/parent/child"
is "$_BB_EXIT" "0" "rmdir 先删除子空目录成功"
bb_run rmdir "$TMPDIR/parent"
is "$_BB_EXIT" "0" "rmdir 再删除父空目录成功"

done_testing
