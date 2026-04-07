#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 基本路径
bb_run basename "/a/b/c.txt"
is "$_BB_STDOUT" "c.txt" "basename 提取文件名"

# 去后缀
bb_run basename "/a/b/c.txt" ".txt"
is "$_BB_STDOUT" "c" "basename 去后缀"

# 尾部斜杠
bb_run basename "/a/b/"
is "$_BB_STDOUT" "b" "basename 尾部斜杠"

# 相对路径
bb_run basename "foo/bar"
is "$_BB_STDOUT" "bar" "basename 相对路径"

# 单个文件名
bb_run basename "test.txt"
is "$_BB_STDOUT" "test.txt" "basename 单文件名"

# -a 多个路径
bb_run basename -a /a/b /c/d
is "$_BB_STDOUT" $'b\nd' "basename -a 多路径"

# -s 去后缀（多文件）
bb_run basename -a -s .txt /a/b.txt /c/d.txt
is "$_BB_STDOUT" $'b\nd' "basename -a -s 多文件去后缀"

# POSIX 规定 basename "" 返回空字符串且 exit 0，不报错
bb_run basename ""
is "$_BB_STDOUT" "" "basename 空路径返回空字符串"

done_testing
