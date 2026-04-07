#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 字符串相等
bb_run test "hello" = "hello"
is "$_BB_EXIT" "0" "test 字符串相等"

# 字符串不等
bb_run test "hello" != "world"
is "$_BB_EXIT" "0" "test 字符串不等"

# 空字符串
bb_run test -n "hello"
is "$_BB_EXIT" "0" "test -n 非空字符串"

bb_run test -z ""
is "$_BB_EXIT" "0" "test -z 空字符串"

# 数字比较
bb_run test 5 -eq 5
is "$_BB_EXIT" "0" "test -eq 数字相等"

bb_run test 5 -gt 3
is "$_BB_EXIT" "0" "test -gt 大于"

bb_run test 3 -lt 5
is "$_BB_EXIT" "0" "test -lt 小于"

# 文件存在
mkfile "exists.txt" "data"
bb_run test -f "$TMPDIR/exists.txt"
is "$_BB_EXIT" "0" "test -f 文件存在"

# 文件不存在
bb_run test -f "$TMPDIR/nope.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "test -f 文件不存在"

# ! 取反
bb_run test ! -f "$TMPDIR/nope.txt"
is "$_BB_EXIT" "0" "test ! 取反"

done_testing
