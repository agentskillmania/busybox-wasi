#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 加法
bb_run expr 2 + 3
is "$_BB_STDOUT" "5" "expr 加法 2 + 3 = 5"

# 乘法（需要转义 *）
bb_run expr 10 \* 5
is "$_BB_STDOUT" "50" "expr 乘法 10 * 5 = 50"

# 减法
bb_run expr 10 - 3
is "$_BB_STDOUT" "7" "expr 减法 10 - 3 = 7"

# 除法
bb_run expr 10 / 3
is "$_BB_STDOUT" "3" "expr 除法 10 / 3 = 3（整数）"

# 取模
bb_run expr 10 % 3
is "$_BB_STDOUT" "1" "expr 取模 10 %% 3 = 1"

# 比较操作（真返回 1，假返回 0）
bb_run expr 5 \> 3
is "$_BB_STDOUT" "1" "expr 比较 5 > 3 返回 1"

# 比较操作（假）
bb_run expr 3 \> 5
is "$_BB_STDOUT" "0" "expr 比较 3 > 5 返回 0"

# 字符串匹配
bb_run expr hello : 'hel'
is "$_BB_STDOUT" "3" "expr 字符串匹配 hel 长度为 3"

# 等式比较
bb_run expr 5 = 5
is "$_BB_STDOUT" "1" "expr 等式 5 = 5 返回 1"

# 无效表达式
bb_run expr 2 +
cmp_ok "$_BB_EXIT" "!=" "0" "expr 无效表达式返回非零退出码"

done_testing
