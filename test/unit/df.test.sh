#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# df 显示磁盘使用信息（WASI 中信息可能有限）
bb_run df
is "$_BB_EXIT" "0" "df 显示磁盘信息成功"

# df 输出应包含一些头部信息
like "$_BB_STDOUT" "Filesystem|Size|Used|Avail|Use%|Mounted on" "df 输出包含表头"

# df -h 人类可读格式
bb_run df -h
is "$_BB_EXIT" "0" "df -h 人类可读格式成功"

# df -k 以 1K 块为单位
bb_run df -k
is "$_BB_EXIT" "0" "df -k 以1K块为单位成功"

# df 指定路径
bb_run df "$TMPDIR"
is "$_BB_EXIT" "0" "df 指定路径成功"

# df 不存在的路径应失败
bb_run df "$TMPDIR/nonexistent_df_path"
cmp_ok "$_BB_EXIT" "!=" "0" "df 不存在的路径返回非零"

done_testing
