#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# printenv 基本调用
bb_run printenv
is "$_BB_EXIT" "0" "printenv 不崩溃"

# 输出非空
bb_run printenv
isnt "$_BB_STDOUT" "" "printenv 输出非空"

# printenv HOME
bb_run printenv HOME
is "$_BB_EXIT" "0" "printenv HOME 不崩溃"

# printenv HOME 输出非空
bb_run printenv HOME
isnt "$_BB_STDOUT" "" "printenv HOME 输出非空"

# printenv 不存在的变量
bb_run printenv NONEXISTENT_VAR_XYZ
cmp_ok "$_BB_EXIT" "!=" "0" "printenv 不存在的变量返回非零"

# 通过 wsh 调用
bb_run_wsh 'printenv'
is "$_BB_EXIT" "0" "printenv 在 wsh 中正常"

# printenv 输出格式 KEY=VALUE
bb_run printenv
like "$_BB_STDOUT" "=" "printenv 输出包含等号分隔的键值"

done_testing
