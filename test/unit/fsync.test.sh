#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# fsync 基本调用
file=$(mkfile "test.txt" "hello")
bb_run fsync "$file"
# WASM 中 fsync 可能是 stub，但不应崩溃
is "$_BB_EXIT" "0" "fsync 文件不崩溃"

# 无参数应报错
bb_run fsync
cmp_ok "$_BB_EXIT" "!=" "0" "fsync 无参数返回非零"

# 不存在的文件
bb_run fsync "$_TEST_TMPDIR/nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "fsync 不存在的文件返回非零"

# 无输出
bb_run fsync "$file"
is "$_BB_STDOUT" "" "fsync 无输出"

# 通过 wsh 调用
bb_run_wsh "fsync $file"
is "$_BB_EXIT" "0" "fsync 在 wsh 中不崩溃"

done_testing
