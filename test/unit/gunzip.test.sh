#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# gunzip 是 gzip 的解压别名，在 WASI 中正常工作

# gunzip 原地解压文件
mkfile "gz_test.txt" "test"
bb_run gzip "$TMPDIR/gz_test.txt"
is "$_BB_EXIT" "0" "gzip 压缩文件成功"

bb_run gunzip "$TMPDIR/gz_test.txt.gz"
is "$_BB_EXIT" "0" "gunzip 解压文件成功"

# gunzip 不存在的文件
bb_run gunzip "$TMPDIR/nonexistent.gz"
cmp_ok "$_BB_EXIT" "!=" "0" "gunzip 不存在的文件返回非零"

# gunzip -c stdin
bb_run_stdin "hello" gzip -c
cmp_ok "$_BB_EXIT" "==" "0" "gzip -c stdin 可用"

done_testing
