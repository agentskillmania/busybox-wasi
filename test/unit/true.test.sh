#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# 基本调用
bb_run true
is "$_BB_EXIT" "0" "true 返回 0"

# 带参数（应忽略）
bb_run true whatever
is "$_BB_EXIT" "0" "true 带参数仍返回 0"

# 通过 wsh 调用
bb_run_wsh 'true'
is "$_BB_EXIT" "0" "wsh 中 true 返回 0"

done_testing
