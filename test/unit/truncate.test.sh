#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 截断为 0 字节
f1=$(mkfile "trunc.txt" "hello world")
bb_run truncate -s 0 "$f1"
is "$_BB_EXIT" "0" "truncate -s 0 截断为空文件成功"
bb_run cat "$f1"
is "$_BB_STDOUT" "" "truncate -s 0 后文件为空"

# 截断为指定大小
mkfile "trunc_size.txt" "1234567890"
bb_run truncate -s 5 "$TMPDIR/trunc_size.txt"
is "$_BB_EXIT" "0" "truncate -s 5 截断到5字节成功"
bb_run cat "$TMPDIR/trunc_size.txt"
is "$_BB_STDOUT" "12345" "truncate -s 5 截断后内容正确"

# 扩展文件大小
mkfile "trunc_expand.txt" "hi"
bb_run truncate -s 10 "$TMPDIR/trunc_expand.txt"
is "$_BB_EXIT" "0" "truncate 扩展文件大小成功"

# 相对大小 +10 扩展
mkfile "trunc_rel.txt" "abc"
bb_run truncate -s +5 "$TMPDIR/trunc_rel.txt"
is "$_BB_EXIT" "0" "truncate -s +5 相对扩展成功"

# 缺少 -s 参数应失败
mkfile "trunc_nos.txt" "data"
bb_run truncate "$TMPDIR/trunc_nos.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "truncate 缺少 -s 参数返回非零"

# 文件不存在应失败
bb_run truncate -s 10 "$TMPDIR/nonexistent_trunc.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "truncate 文件不存在返回非零"

done_testing
