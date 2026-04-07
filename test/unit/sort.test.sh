#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 基本排序
bb_run_stdin $'banana\napple\ncherry' sort
is "$_BB_STDOUT" $'apple\nbanana\ncherry' "sort 基本排序"

# 倒序
bb_run_stdin $'a\nc\nb' sort -r
is "$_BB_STDOUT" $'c\nb\na' "sort -r 倒序"

# 数字排序
bb_run_stdin $'10\n2\n1\n20' sort -n
is "$_BB_STDOUT" $'1\n2\n10\n20' "sort -n 数字排序"

# 去重
bb_run_stdin $'a\nb\na\nc\nb' sort -u
is "$_BB_STDOUT" $'a\nb\nc' "sort -u 去重"

# 按字段排序
bb_run_stdin $'b 2\na 1\nc 3' sort -k2 -n
is "$_BB_STDOUT" $'a 1\nb 2\nc 3' "sort -k 按字段排序"

# 按分隔符排序
bb_run_stdin $'b:2\na:1\nc:3' sort -t: -k2 -n
is "$_BB_STDOUT" $'a:1\nb:2\nc:3' "sort -t 自定义分隔符"

# 空输入
bb_run_stdin "" sort
is "$_BB_STDOUT" "" "sort 空输入"

# 文件排序
f=$(mkfile "data.txt" $'cherry\napple\nbanana')
bb_run sort "$f"
is "$_BB_STDOUT" $'apple\nbanana\ncherry' "sort 从文件读取"

# -c 检查是否有序
bb_run_stdin $'a\nb\nc' sort -c
is "$_BB_EXIT" "0" "sort -c 已有序返回 0"

# -c 未排序
bb_run_stdin $'c\na\nb' sort -c
cmp_ok "$_BB_EXIT" "!=" "0" "sort -c 未排序返回非零"

done_testing
