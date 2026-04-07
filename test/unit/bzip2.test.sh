#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# bzip2 原地压缩/解压需要 dup()，WASI 不支持
# 但 stdin 管道模式可以工作

# bzip2 -c stdin 压缩
bb_run_stdin "hello bzip2" bzip2 -c
is "$_BB_EXIT" "0" "bzip2 -c stdin 压缩成功"
cmp_ok "${#_BB_STDOUT}" ">" "0" "bzip2 -c 输出非空"

# bzip2 原地压缩文件应失败
mkfile "bz_file.txt" "test data"
bb_run bzip2 "$TMPDIR/bz_file.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "bzip2 原地压缩因 dup 限制失败"

# bzip2 -c 文件也应失败
bb_run bzip2 -c "$TMPDIR/bz_file.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "bzip2 -c 文件因 dup 限制失败"

# bzip2 -k 保留原文件也应失败
bb_run bzip2 -k "$TMPDIR/bz_file.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "bzip2 -k 因 dup 限制失败"

done_testing
