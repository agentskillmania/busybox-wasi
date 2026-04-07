#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# env 基本调用（列出所有环境变量）
bb_run env
is "$_BB_EXIT" "0" "env 列出环境变量不崩溃"

# 输出非空
bb_run env
isnt "$_BB_STDOUT" "" "env 输出非空"

# env VAR=val command 格式
bb_run env MYVAR=hello echo hello
is "$_BB_STDOUT" "hello" "env VAR=val command 格式正确"

# env -i 清空环境
bb_run env -i
is "$_BB_STDOUT" "" "env -i 清空环境后无输出"

# 通过 wsh 调用
bb_run_wsh 'env'
is "$_BB_EXIT" "0" "env 在 wsh 中正常"

# env 设置多个变量
bb_run env A=1 B=2 printf '%s %s' 1 2
is "$_BB_EXIT" "0" "env 设置多个变量不崩溃"

# env 输出包含 KEY=VALUE 格式
bb_run env
like "$_BB_STDOUT" "[A-Za-z_][A-Za-z0-9_]*=" "env 输出包含 KEY=VALUE 格式"

done_testing
