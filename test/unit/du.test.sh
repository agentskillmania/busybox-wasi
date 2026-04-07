#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# du 对目录
mkdir -p "$TMPDIR/du_dir"
mkfile "du_dir/a.txt" "aaaa"
mkfile "du_dir/b.txt" "bbbbbbbb"
bb_run du "$TMPDIR/du_dir"
is "$_BB_EXIT" "0" "du 计算目录磁盘使用成功"
like "$_BB_STDOUT" "du_dir" "du 输出包含目录名"

# du 对单个文件
mkfile "du_file.txt" "hello du world"
bb_run du "$TMPDIR/du_file.txt"
is "$_BB_EXIT" "0" "du 计算单个文件成功"
like "$_BB_STDOUT" "du_file.txt" "du 单文件输出包含文件名"

# du -s 摘要模式
bb_run du -s "$TMPDIR/du_dir"
is "$_BB_EXIT" "0" "du -s 摘要模式成功"
unlike "$_BB_STDOUT" $'\n' "du -s 输出只有一行摘要"

# du -h 人类可读格式
bb_run du -h "$TMPDIR/du_file.txt"
is "$_BB_EXIT" "0" "du -h 人类可读格式成功"
like "$_BB_STDOUT" "[0-9]+[KMGTP]?" "du -h 输出包含大小和单位"

# du -a 显示所有文件
bb_run du -a "$TMPDIR/du_dir"
is "$_BB_EXIT" "0" "du -a 显示所有文件成功"
like "$_BB_STDOUT" "a.txt" "du -a 输出包含子文件"

# du 不存在的路径应失败
bb_run du "$TMPDIR/nonexistent_du"
cmp_ok "$_BB_EXIT" "!=" "0" "du 不存在的路径返回非零"

# du 多路径
bb_run du "$TMPDIR/du_dir" "$TMPDIR/du_file.txt"
is "$_BB_EXIT" "0" "du 多路径成功"

done_testing
