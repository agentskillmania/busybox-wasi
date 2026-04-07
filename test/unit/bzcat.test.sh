#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# bzcat 读取压缩文件需要 dup()，WASI 不支持

# bzcat 文件应失败
mkfile "bzcat_test.txt" "bzcat test"
bb_run bzip2 "$TMPDIR/bzcat_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "bzip2 压缩因 dup 限制失败"

bb_run bzcat "$TMPDIR/bzcat_test.txt.bz2"
cmp_ok "$_BB_EXIT" "!=" "0" "bzcat 因 dup 限制失败"

# bzcat 不存在的文件
bb_run bzcat "$TMPDIR/nonexistent.bz2"
cmp_ok "$_BB_EXIT" "!=" "0" "bzcat 不存在的文件返回非零"

# bzcat stdin 模式
bb_run_stdin "hello" bzip2 -c
cmp_ok "$_BB_EXIT" "==" "0" "bzip2 -c stdin 可用"

done_testing
