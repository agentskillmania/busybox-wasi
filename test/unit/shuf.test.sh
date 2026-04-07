#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 13

# ========== -e 直接指定元素 ==========
bb_run shuf -e a b c d
is "$_BB_EXIT" "0" "shuf -e 成功退出码 0"
# 验证输出包含所有元素（不验证顺序）
like "$_BB_STDOUT" "a" "shuf -e 输出包含 a"
like "$_BB_STDOUT" "b" "shuf -e 输出包含 b"
like "$_BB_STDOUT" "c" "shuf -e 输出包含 c"
like "$_BB_STDOUT" "d" "shuf -e 输出包含 d"

# ========== -n 限制输出数量 ==========
bb_run shuf -e a b c d -n 2
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "2" "shuf -n 2 只输出 2 行"

# ========== -i 数字范围 ==========
bb_run shuf -i 1-5
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "5" "shuf -i 1-5 输出 5 个数字"
# 验证包含所有数字
like "$_BB_STDOUT" "1" "shuf -i 输出包含 1"
like "$_BB_STDOUT" "5" "shuf -i 输出包含 5"

# ========== 从文件读取 ==========
f=$(mkfile "data.txt" $'alpha\nbeta\ngamma')
bb_run shuf "$f"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "3" "shuf 从文件读取输出 3 行"

# ========== 验证输出元素完整（不验证顺序）==========
like "$_BB_STDOUT" "alpha" "shuf 文件输出包含 alpha"
like "$_BB_STDOUT" "beta" "shuf 文件输出包含 beta"
like "$_BB_STDOUT" "gamma" "shuf 文件输出包含 gamma"

done_testing
