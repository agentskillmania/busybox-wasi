#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# gunzip 是 gzip 的解压别名，同样受 dup 限制

# gunzip 原地解压文件需要 dup，应失败
mkfile "gz_test.txt" "test"
bb_run gzip "$TMPDIR/gz_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "gzip 压缩文件因 dup 限制失败"

bb_run gunzip "$TMPDIR/gz_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "gunzip 解压文件因 dup 限制失败"

# gunzip 不存在的文件
bb_run gunzip "$TMPDIR/nonexistent.gz"
cmp_ok "$_BB_EXIT" "!=" "0" "gunzip 不存在的文件返回非零"

# gunzip -c stdin
bb_run_stdin "hello" gzip -c
cmp_ok "$_BB_EXIT" "==" "0" "gzip -c stdin 可用"

done_testing
