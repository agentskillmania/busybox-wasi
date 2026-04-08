#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# bzcat 读取压缩文件在 WASI 中正常工作

# bzcat 文件解压到 stdout
mkfile "bzcat_test.txt" "bzcat test"
bb_run bzip2 "$TMPDIR/bzcat_test.txt"
is "$_BB_EXIT" "0" "bzip2 压缩成功"

bb_run bzcat "$TMPDIR/bzcat_test.txt.bz2"
is "$_BB_EXIT" "0" "bzcat 解压成功"
is "$_BB_STDOUT" "bzcat test" "bzcat 输出内容正确"

# bzcat 不存在的文件
bb_run bzcat "$TMPDIR/nonexistent.bz2"
cmp_ok "$_BB_EXIT" "!=" "0" "bzcat 不存在的文件返回非零"

# bzcat stdin 模式
bb_run_stdin "hello" bzip2 -c
cmp_ok "$_BB_EXIT" "==" "0" "bzip2 -c stdin 可用"

done_testing
