#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# tty 基本调用
bb_run tty
# 在 wasmtime 中可能返回 "not a tty"，但不应崩溃
is "$_BB_EXIT" "0" "tty 不崩溃（可能返回 not a tty）"

# 输出非空
bb_run tty
isnt "$_BB_STDOUT" "" "tty 输出非空"

# 输出包含 tty 相关信息
bb_run tty
like "$_BB_STDOUT" "(tty|not a tty)" "tty 输出包含 tty 相关信息"

# -s 静默模式
bb_run tty -s
is "$_BB_STDOUT" "" "tty -s 无输出"

# 在 wsh 中调用
bb_run_wsh 'tty'
is "$_BB_EXIT" "0" "tty 在 wsh 中不崩溃"

done_testing
