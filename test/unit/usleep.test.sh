#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# usleep 0 立即返回
bb_run usleep 0
is "$_BB_EXIT" "0" "usleep 0 立即返回"

# usleep 1000（1 毫秒）
bb_run usleep 1000
is "$_BB_EXIT" "0" "usleep 1000 微秒正常完成"

# usleep 无参数应报错
bb_run usleep
cmp_ok "$_BB_EXIT" "!=" "0" "usleep 无参数返回非零"

# 通过 wsh 调用
bb_run_wsh 'usleep 0'
is "$_BB_EXIT" "0" "usleep 0 在 wsh 中正常"

# usleep 输出应为空
bb_run usleep 0
is "$_BB_STDOUT" "" "usleep 无输出"

done_testing
