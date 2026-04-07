#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# BusyBox 编译时 lzma 只支持解压（和 xz 一样）
# 所以 lzma 压缩功能不可用

# lzma 无 -d 参数时应报错
bb_run lzma
cmp_ok "$_BB_EXIT" "!=" "0" "lzma 无参数返回非零"

# lzma 原地压缩文件应失败
mkfile "lzma_test.txt" "test"
bb_run lzma "$TMPDIR/lzma_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "lzma 压缩不可用"

# lzma 不存在的文件
bb_run lzma "$TMPDIR/nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "lzma 不存在的文件返回非零"

done_testing
