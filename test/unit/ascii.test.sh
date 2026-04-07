#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# ascii 基本调用
bb_run ascii
is "$_BB_EXIT" "0" "ascii 不崩溃"

# 输出非空
bb_run ascii
isnt "$_BB_STDOUT" "" "ascii 输出非空"

# 输出应包含已知的 ASCII 值（A = 65）
bb_run ascii
like "$_BB_STDOUT" "65" "ascii 输出包含 65（A）"

# 输出应包含字符 A
bb_run ascii
like "$_BB_STDOUT" "A" "ascii 输出包含字符 A"

# 通过 wsh 调用
bb_run_wsh 'ascii'
is "$_BB_EXIT" "0" "ascii 在 wsh 中正常"

# 输出包含十六进制或八进制
bb_run ascii
like "$_BB_STDOUT" "(0x4|101)" "ascii 输出包含十六进制 0x4 或八进制 101（A）"

# 输出行数合理
bb_run ascii
cmp_ok "$(echo "$_BB_STDOUT" | wc -l)" ">=" "5" "ascii 输出至少 5 行"

done_testing
