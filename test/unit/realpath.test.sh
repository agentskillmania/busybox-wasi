#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# realpath 获取文件真实路径
f1=$(mkfile "real.txt" "realpath data")
bb_run realpath "$f1"
is "$_BB_EXIT" "0" "realpath 获取文件路径成功"
like "$_BB_STDOUT" "real.txt" "realpath 输出包含文件名"

# realpath 对目录
mkdir -p "$TMPDIR/real_dir"
bb_run realpath "$TMPDIR/real_dir"
is "$_BB_EXIT" "0" "realpath 对目录成功"
like "$_BB_STDOUT" "real_dir" "realpath 目录输出包含目录名"

# realpath -m 不要求路径存在
bb_run realpath -m "$TMPDIR/no_such_path/file.txt"
is "$_BB_EXIT" "0" "realpath -m 对不存在的路径成功"
like "$_BB_STDOUT" "no_such_path" "realpath -m 输出包含路径部分"

# realpath -s 不解析符号链接
bb_run realpath -s "$f1"
is "$_BB_EXIT" "0" "realpath -s 不解析符号链接成功"

# realpath 对不存在的文件不带 -m 应失败
bb_run realpath "$TMPDIR/definitely_missing"
cmp_ok "$_BB_EXIT" "!=" "0" "realpath 不存在的文件返回非零"

done_testing
