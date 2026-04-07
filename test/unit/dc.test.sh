#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 基本加法：压入 2 和 3，相加，打印
bb_run_stdin "2 3 + p" dc
is "$_BB_STDOUT" "5" "dc 加法 2 3 + p = 5"

# 减法
bb_run_stdin "10 3 - p" dc
is "$_BB_STDOUT" "7" "dc 减法 10 3 - p = 7"

# 乘法
bb_run_stdin "4 5 * p" dc
is "$_BB_STDOUT" "20" "dc 乘法 4 5 * p = 20"

# 除法
bb_run_stdin "10 3 / p" dc
is "$_BB_STDOUT" "3" "dc 整数除法 10 3 / p = 3"

# 幂运算
bb_run_stdin "2 10 ^ p" dc
is "$_BB_STDOUT" "1024" "dc 幂运算 2 10 ^ p = 1024"

# 取模
bb_run_stdin "10 3 % p" dc
is "$_BB_STDOUT" "1" "dc 取模 10 3 %% p = 1"

# 多个操作
bb_run_stdin "5 3 + 2 * p" dc
is "$_BB_STDOUT" "16" "dc 复合运算 (5+3)*2 = 16"

# 空输入
bb_run_stdin "" dc
is "$_BB_EXIT" "0" "dc 空输入不崩溃"

done_testing
