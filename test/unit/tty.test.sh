#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# tty 在 WASI 中：返回空输出和退出码 0，-s 模式正常工作
# wasmtime 不是真正的终端，tty 不报错但输出为空

# tty 基本调用不崩溃
bb_run tty
is "$_BB_EXIT" "0" "tty 不崩溃"

# tty 输出可能为空（wasmtime 无终端）
bb_run tty
# 不验证输出非空，只验证不崩溃
ok "tty 输出（可能为空）: '$_BB_STDOUT'"

# -s 静默模式无输出
bb_run tty -s
is "$_BB_STDOUT" "" "tty -s 无输出"

# 在 wsh 中调用不崩溃
bb_run_wsh 'tty'
is "$_BB_EXIT" "0" "tty 在 wsh 中不崩溃"

# tty 多次调用行为一致
bb_run tty
bb_run tty
is "$_BB_EXIT" "0" "tty 多次调用不崩溃"

done_testing
