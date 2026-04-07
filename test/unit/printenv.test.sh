#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# printenv 基本调用（需要带环境变量，默认 wasmtime 不传）
bb_run_env printenv
is "$_BB_EXIT" "0" "printenv 不崩溃"

# 输出非空
bb_run_env printenv
isnt "$_BB_STDOUT" "" "printenv 输出非空"

# printenv HOME
bb_run_env printenv HOME
is "$_BB_EXIT" "0" "printenv HOME 不崩溃"
is "$_BB_STDOUT" "/root" "printenv HOME 输出 /root"

# printenv 不存在的变量
bb_run printenv NONEXISTENT_VAR_XYZ
cmp_ok "$_BB_EXIT" "!=" "0" "printenv 不存在的变量返回非零"

# 通过 wsh 调用（wsh 没有环境变量，跳过）
skip "printenv 在 wsh 中无环境变量（WASI 不传入）"

# printenv 输出格式 KEY=VALUE
bb_run_env printenv
like "$_BB_STDOUT" "=" "printenv 输出包含等号分隔的键值"

done_testing
