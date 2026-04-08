#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# bzip2 压缩/解压在 WASI 中正常工作
# stdin 管道模式和文件模式均可用

# bzip2 -c stdin 压缩
bb_run_stdin "hello bzip2" bzip2 -c
is "$_BB_EXIT" "0" "bzip2 -c stdin 压缩成功"
cmp_ok "${#_BB_STDOUT}" ">" "0" "bzip2 -c 输出非空"

# bzip2 原地压缩文件
mkfile "bz_file.txt" "test data"
bb_run bzip2 "$TMPDIR/bz_file.txt"
is "$_BB_EXIT" "0" "bzip2 原地压缩成功"
ok "[ -f $TMPDIR/bz_file.txt.bz2 ]" "bzip2 压缩后 .bz2 文件存在"

# bzip2 -c 文件压缩
bb_run bzip2 -c "$TMPDIR/bz_file.txt.bz2"
is "$_BB_EXIT" "0" "bzip2 -c 文件压缩成功"

# bzip2 -k 保留原文件压缩
mkfile "bz_file2.txt" "more data"
bb_run bzip2 -k "$TMPDIR/bz_file2.txt"
is "$_BB_EXIT" "0" "bzip2 -k 保留原文件压缩成功"
ok "[ -f $TMPDIR/bz_file2.txt ]" "bzip2 -k 原文件仍存在"

done_testing
