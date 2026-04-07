#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# pwd 输出
bb_run pwd
is "$_BB_EXIT" "0" "pwd 返回 0"
isnt "$_BB_STDOUT" "" "pwd 输出非空"

# 输出应该是路径格式
like "$_BB_STDOUT" '^/' "pwd 输出以 / 开头"

done_testing
