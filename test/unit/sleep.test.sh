#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# sleep 0 立即返回
bb_run sleep 0
is "$_BB_EXIT" "0" "sleep 0 立即返回"

# sleep 0.1 秒
bb_run sleep 0.1
is "$_BB_EXIT" "0" "sleep 0.1 正常完成"

# sleep 1s（整数秒）
bb_run sleep 1
is "$_BB_EXIT" "0" "sleep 1 正常完成"

# sleep 无参数应报错
bb_run sleep
cmp_ok "$_BB_EXIT" "!=" "0" "sleep 无参数返回非零"

# 通过 wsh 调用
bb_run_wsh 'sleep 0'
is "$_BB_EXIT" "0" "sleep 0 在 wsh 中正常"

# 负数（可能报错或忽略）
bb_run sleep -1
cmp_ok "$_BB_EXIT" "!=" "0" "sleep 负数返回非零"

done_testing
