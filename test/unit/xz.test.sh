#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# BusyBox 编译时 xz 只支持解压（xz --help 显示只有 -d 选项）
# 所以 xz 压缩功能不可用

# xz 无 -d 参数时应报错
bb_run xz
cmp_ok "$_BB_EXIT" "!=" "0" "xz 无参数返回非零"

# xz 原地压缩文件（如果有的话）也应失败
mkfile "xz_test.txt" "test"
bb_run xz "$TMPDIR/xz_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "xz 压缩不可用"

# xz 不存在的文件
bb_run xz "$TMPDIR/nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "xz 不存在的文件返回非零"

done_testing
