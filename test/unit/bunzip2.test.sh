#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# bunzip2 原地解压在 WASI 中正常工作

# bunzip2 原地解压
mkfile "bz_test.txt" "test"
bb_run bzip2 "$TMPDIR/bz_test.txt"
is "$_BB_EXIT" "0" "bzip2 压缩成功"

bb_run bunzip2 "$TMPDIR/bz_test.txt.bz2"
is "$_BB_EXIT" "0" "bunzip2 解压成功"

# bunzip2 不存在的文件
bb_run bunzip2 "$TMPDIR/nonexistent.bz2"
cmp_ok "$_BB_EXIT" "!=" "0" "bunzip2 不存在的文件返回非零"

# bunzip2 -c stdin 可以工作
bb_run_stdin "hello" bzip2 -c
cmp_ok "$_BB_EXIT" "==" "0" "bzip2 -c stdin 可用"

done_testing
