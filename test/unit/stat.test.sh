#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# stat 获取文件信息
f1=$(mkfile "stat_file.txt" "stat data")
bb_run stat "$f1"
is "$_BB_EXIT" "0" "stat 获取文件信息成功"

# stat -c 自定义格式 %s 文件大小
bb_run stat -c "%s" "$f1"
is "$_BB_EXIT" "0" "stat -c %s 获取文件大小成功"
is "$_BB_STDOUT" "9" "stat -c %s 返回正确文件大小"

# stat -c %n 文件名
bb_run stat -c "%n" "$f1"
is "$_BB_EXIT" "0" "stat -c %n 获取文件名成功"
like "$_BB_STDOUT" "stat_file.txt" "stat -c %n 输出包含文件名"

# stat 对目录
mkdir -p "$TMPDIR/stat_dir"
bb_run stat "$TMPDIR/stat_dir"
is "$_BB_EXIT" "0" "stat 获取目录信息成功"

# stat -f 文件系统信息
bb_run stat -f "$TMPDIR"
is "$_BB_EXIT" "0" "stat -f 获取文件系统信息成功"

# stat 多文件
mkfile "stat_f2.txt" "second"
bb_run stat "$f1" "$TMPDIR/stat_f2.txt"
is "$_BB_EXIT" "0" "stat 多个文件成功"

# stat 不存在的文件应失败
bb_run stat "$TMPDIR/nonexistent_stat.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "stat 不存在的文件返回非零"

# stat -c %a 权限八进制
bb_run stat -c "%a" "$f1"
is "$_BB_EXIT" "0" "stat -c %a 获取权限成功"

done_testing
