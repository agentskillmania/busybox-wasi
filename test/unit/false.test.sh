#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# 基本调用
bb_run false
cmp_ok "$_BB_EXIT" "!=" "0" "false 返回非零"

# 带参数
bb_run false whatever
cmp_ok "$_BB_EXIT" "!=" "0" "false 带参数仍返回非零"

# 通过 wsh 调用
bb_run_wsh 'false; echo $?'
like "$_BB_STDOUT" "1" "wsh 中 false 退出码为 1"

done_testing
