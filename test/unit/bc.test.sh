#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 基本加法
bb_run_stdin "2+3" bc
is "$_BB_STDOUT" "5" "bc 加法 2+3 = 5"

# 基本减法
bb_run_stdin "10-3" bc
is "$_BB_STDOUT" "7" "bc 减法 10-3 = 7"

# 乘法
bb_run_stdin "4*5" bc
is "$_BB_STDOUT" "20" "bc 乘法 4*5 = 20"

# 除法（整数）
bb_run_stdin "10/3" bc
is "$_BB_STDOUT" "3" "bc 整数除法 10/3 = 3"

# scale 设置精度
bb_run_stdin "scale=2; 1/3" bc
like "$_BB_STDOUT" "^0?\.33" "bc scale=2; 1/3 约 0.33"

# 幂运算
bb_run_stdin "2^10" bc
is "$_BB_STDOUT" "1024" "bc 幂运算 2^10 = 1024"

# 括号运算
bb_run_stdin "(2+3)*4" bc
is "$_BB_STDOUT" "20" "bc 括号运算 (2+3)*4 = 20"

# 负数
bb_run_stdin "-5+3" bc
is "$_BB_STDOUT" "-2" "bc 负数 -5+3 = -2"

# 多行表达式
bb_run_stdin "x=5
y=3
x+y" bc
is "$_BB_STDOUT" "8" "bc 多行表达式 x=5, y=3, x+y = 8"

# 空输入
bb_run_stdin "" bc
is "$_BB_EXIT" "0" "bc 空输入不崩溃"

done_testing
