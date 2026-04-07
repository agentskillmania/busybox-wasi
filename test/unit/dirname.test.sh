#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 基本路径
bb_run dirname "/a/b/c"
is "$_BB_STDOUT" "/a/b" "dirname 提取目录部分"

# 末尾斜杠
bb_run dirname "/a/b/"
is "$_BB_STDOUT" "/a" "dirname 末尾斜杠"

# 相对路径
bb_run dirname "foo/bar.txt"
is "$_BB_STDOUT" "foo" "dirname 相对路径"

# 单文件名
bb_run dirname "file.txt"
is "$_BB_STDOUT" "." "dirname 单文件名返回 ."

# 根目录
bb_run dirname "/"
is "$_BB_STDOUT" "/" "dirname 根目录返回 /"

# 多级路径
bb_run dirname "/a/b/c/d"
is "$_BB_STDOUT" "/a/b/c" "dirname 多级路径"

done_testing
