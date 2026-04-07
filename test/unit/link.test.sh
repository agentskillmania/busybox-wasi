#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 创建硬链接
f1=$(mkfile "link_src.txt" "hard link data")
bb_run link "$f1" "$TMPDIR/link_dst.txt"
is "$_BB_EXIT" "0" "link 创建硬链接成功"
bb_run cat "$TMPDIR/link_dst.txt"
is "$_BB_STDOUT" "hard link data" "link 硬链接内容正确"

# 源文件不存在应失败
bb_run link "$TMPDIR/nonexistent_link_src" "$TMPDIR/link_bad"
cmp_ok "$_BB_EXIT" "!=" "0" "link 源文件不存在返回非零"

# 目标已存在应失败
mkfile "link_existing.txt" "existing"
bb_run link "$f1" "$TMPDIR/link_existing.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "link 目标已存在返回非零"

# 修改硬链接后原文件内容同步
mkfile "link_sync.txt" "original"
bb_run link "$TMPDIR/link_sync.txt" "$TMPDIR/link_sync2.txt"
is "$_BB_EXIT" "0" "link 创建第二个硬链接成功"
printf "modified" > "$TMPDIR/link_sync.txt"
bb_run cat "$TMPDIR/link_sync2.txt"
is "$_BB_STDOUT" "modified" "link 硬链接修改后内容同步"

done_testing
