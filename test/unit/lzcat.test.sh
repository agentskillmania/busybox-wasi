#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# lzcat = lzma -c -d，和 xzcat 同理
# BusyBox lzma 只支持解压

# lzcat 不存在的文件
bb_run lzcat "$TMPDIR/nonexistent.lzma"
cmp_ok "$_BB_EXIT" "!=" "0" "lzcat 不存在的文件返回非零"

# lzcat 无参数
bb_run lzcat
cmp_ok "$_BB_EXIT" "!=" "0" "lzcat 无参数返回非零"

# lzcat 无参数不崩溃
bb_run lzcat --help 2>/dev/null
ok "lzcat 不崩溃"

done_testing
