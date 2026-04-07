#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# date 输出非空
bb_run date
is "$_BB_EXIT" "0" "date 返回 0"
isnt "$_BB_STDOUT" "" "date 输出非空"

# 包含年份
year=$(date +%Y)
bb_run date
like "$_BB_STDOUT" "$year" "date 包含当前年份"

# +%s 时间戳
bb_run date +%s
like "$_BB_STDOUT" '^[0-9]+$' "date +%s 输出时间戳"

# -u UTC
bb_run date -u
is "$_BB_EXIT" "0" "date -u UTC 模式"

done_testing
