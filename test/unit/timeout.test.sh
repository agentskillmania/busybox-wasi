#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# timeout 运行快速命令
bb_run timeout 5 true
is "$_BB_EXIT" "0" "timeout 5 true 正常退出"

# timeout 运行较长命令（应被超时）
bb_run timeout 0.1 sleep 10
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 0.1 sleep 10 超时返回非零"

# timeout 超时退出码 124（若支持）
bb_run timeout 0.1 sleep 10
# busybox timeout 超时时返回 124 或其他非零值
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 超时后退出码非零"

# timeout 0 秒
bb_run timeout 0 true
is "$_BB_EXIT" "0" "timeout 0 true 正常退出"

# timeout 无参数应报错
bb_run timeout
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 无参数返回非零"

# 通过 wsh 调用
bb_run_wsh 'timeout 5 true'
is "$_BB_EXIT" "0" "timeout 在 wsh 中正常"

# timeout 带 -s 信号
bb_run timeout -s TERM 5 true
is "$_BB_EXIT" "0" "timeout -s TERM 5 true 正常退出"

done_testing
