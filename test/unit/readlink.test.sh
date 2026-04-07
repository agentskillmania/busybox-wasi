#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 创建符号链接用于测试
f1=$(mkfile "rl_target.txt" "readlink data")
ln -s "$f1" "$TMPDIR/rl_link" 2>/dev/null

# readlink 读取符号链接
bb_run readlink "$TMPDIR/rl_link"
is "$_BB_EXIT" "0" "readlink 读取符号链接成功"
like "$_BB_STDOUT" "rl_target" "readlink 输出包含目标名"

# readlink -f 获取规范路径
bb_run readlink -f "$TMPDIR/rl_link"
is "$_BB_EXIT" "0" "readlink -f 获取规范路径成功"
like "$_BB_STDOUT" "rl_target.txt" "readlink -f 输出包含目标文件名"

# readlink 对非符号链接应失败
bb_run readlink "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink 对非符号链接返回非零"

# readlink 不存在的路径应失败
bb_run readlink "$TMPDIR/no_such_link"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink 不存在的路径返回非零"

# 创建嵌套符号链接测试
mkdir -p "$TMPDIR/rl_dir"
mkfile "rl_dir/deep.txt" "deep"
ln -s "$TMPDIR/rl_dir/deep.txt" "$TMPDIR/rl_dirlink" 2>/dev/null
bb_run readlink "$TMPDIR/rl_dirlink"
is "$_BB_EXIT" "0" "readlink 读取嵌套符号链接成功"

done_testing
