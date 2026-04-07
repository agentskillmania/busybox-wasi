#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# yes 默认输出 "y"（需要通过 wsh + head 限制行数）
bb_run_wsh 'yes | head -3'
is "$_BB_EXIT" "0" "yes 通过 wsh 管道不崩溃"

# 验证输出行数
bb_run_wsh 'yes | head -3'
lines=$(echo "$_BB_STDOUT" | wc -l)
is "$lines" "3" "yes | head -3 输出 3 行"

# 默认输出 "y"
bb_run_wsh 'yes | head -1'
is "$(echo "$_BB_STDOUT" | head -1)" "y" "yes 默认输出 y"

# 自定义字符串
bb_run_wsh 'yes hello | head -2'
lines=$(echo "$_BB_STDOUT" | wc -l)
is "$lines" "2" "yes hello | head -2 输出 2 行"

# 自定义字符串内容
bb_run_wsh 'yes hello | head -1'
is "$(echo "$_BB_STDOUT" | head -1)" "hello" "yes hello 输出 hello"

# 多参数
bb_run_wsh 'yes a b | head -1'
is "$(echo "$_BB_STDOUT" | head -1)" "a b" "yes 多参数以空格连接"

done_testing
