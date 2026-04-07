#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# ========== 截断为 0 字节 ==========
f1=$(mkfile "trunc.txt" "hello world")
bb_run truncate -s 0 "$f1"
is "$_BB_EXIT" "0" "truncate -s 0 截断为空文件成功"
bb_run cat "$f1"
is "$_BB_STDOUT" "" "truncate -s 0 后文件为空"

# ========== 截断为指定大小 ==========
f2=$(mkfile "trunc_size.txt" "1234567890")
bb_run truncate -s 5 "$f2"
is "$_BB_EXIT" "0" "truncate -s 5 截断到 5 字节成功"
bb_run cat "$f2"
is "$_BB_STDOUT" "12345" "truncate -s 5 截断后内容正确"

# ========== 缺少 -s 参数应失败 ==========
f3=$(mkfile "trunc_nos.txt" "data")
bb_run truncate "$f3"
cmp_ok "$_BB_EXIT" "!=" "0" "truncate 缺少 -s 参数返回非零"

# BusyBox truncate 不支持 +N 相对大小语法（已删除该测试）
# truncate 文件不存在时带 O_CREAT 自动创建，不返回错误

done_testing
