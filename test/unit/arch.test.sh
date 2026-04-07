#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# arch 基本调用
bb_run arch
is "$_BB_EXIT" "0" "arch 退出码为 0"

# 输出非空
bb_run arch
isnt "$_BB_STDOUT" "" "arch 输出非空"

# arch 等同于 uname -m
bb_run arch
arch_out="$_BB_STDOUT"
bb_run uname -m
uname_m_out="$_BB_STDOUT"
is "$arch_out" "$uname_m_out" "arch 输出与 uname -m 相同"

# 输出不含空格
bb_run arch
like "$_BB_STDOUT" "^[a-zA-Z0-9_\-]+$" "arch 输出是有效的架构名称"

# 通过 wsh 调用
bb_run_wsh 'arch'
is "$_BB_EXIT" "0" "arch 在 wsh 中运行正常"

done_testing
