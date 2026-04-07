#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# cal 基本调用（当月日历）
bb_run cal
is "$_BB_EXIT" "0" "cal 当月日历不崩溃"

# 输出非空
bb_run cal
isnt "$_BB_STDOUT" "" "cal 输出非空"

# cal 2024（整年日历）
bb_run cal 2024
is "$_BB_EXIT" "0" "cal 2024 不崩溃"

# cal 1 2024（2024年1月）
bb_run cal 1 2024
is "$_BB_EXIT" "0" "cal 1 2024 不崩溃"

# cal 1 2024 输出包含 January
bb_run cal 1 2024
like "$_BB_STDOUT" "January" "cal 1 2024 输出包含 January"

# cal 输出包含星期标题
bb_run cal 1 2024
like "$_BB_STDOUT" "Mo|Su" "cal 输出包含星期标题"

# 通过 wsh 调用
bb_run_wsh 'cal'
is "$_BB_EXIT" "0" "cal 在 wsh 中正常"

done_testing
