#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# bunzip2 原地解压需要 dup()，WASI 不支持

# bunzip2 原地解压应失败
mkfile "bz_test.txt" "test"
bb_run bzip2 "$TMPDIR/bz_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "bzip2 压缩因 dup 限制失败"

bb_run bunzip2 "$TMPDIR/bz_test.txt.bz2"
cmp_ok "$_BB_EXIT" "!=" "0" "bunzip2 解压因 dup 限制失败"

# bunzip2 不存在的文件
bb_run bunzip2 "$TMPDIR/nonexistent.bz2"
cmp_ok "$_BB_EXIT" "!=" "0" "bunzip2 不存在的文件返回非零"

# bunzip2 -c stdin 可以工作
bb_run_stdin "hello" bzip2 -c
cmp_ok "$_BB_EXIT" "==" "0" "bzip2 -c stdin 可用"

done_testing
