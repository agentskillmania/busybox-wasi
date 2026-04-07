#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 因数分解 12 = 2 * 2 * 3
bb_run factor 12
like "$_BB_STDOUT" "12: 2 2 3" "factor 12 = 2 2 3"

# 质数 7 = 7
bb_run factor 7
like "$_BB_STDOUT" "7: 7" "factor 7 = 7（质数）"

# 1 的因数
bb_run factor 1
like "$_BB_STDOUT" "1:" "factor 1 输出格式正确"

# 2 的因数（最小质数）
bb_run factor 2
like "$_BB_STDOUT" "2: 2" "factor 2 = 2"

# 大数
bb_run factor 100
like "$_BB_STDOUT" "100: 2 2 5 5" "factor 100 = 2 2 5 5"

# 多个参数
bb_run factor 6 7
like "$_BB_STDOUT" "6: 2 3" "factor 多参数第一个正确"
like "$_BB_STDOUT" "7: 7" "factor 多参数第二个正确"

# 退出码
bb_run factor 42
is "$_BB_EXIT" "0" "factor 正常退出码为 0"

done_testing
