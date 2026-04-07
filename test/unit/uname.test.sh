#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# uname 输出
bb_run uname
is "$_BB_EXIT" "0" "uname 返回 0"
isnt "$_BB_STDOUT" "" "uname 输出非空"

# -a 全部信息
bb_run uname -a
is "$_BB_EXIT" "0" "uname -a 返回 0"
isnt "$_BB_STDOUT" "" "uname -a 输出非空"

# -m 机器架构
bb_run uname -m
isnt "$_BB_STDOUT" "" "uname -m 输出架构"

# -s 内核名
bb_run uname -s
isnt "$_BB_STDOUT" "" "uname -s 输出内核名"

done_testing
