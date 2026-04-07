#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 基本空格转制表符 ==========
bb_run_stdin "hello   world" unexpand
like "$_BB_STDOUT" $'hello\t' "unexpand 空格转制表符"

# ========== -a 转换所有空格序列 ==========
bb_run_stdin "a   b   c" unexpand -a
like "$_BB_STDOUT" $'\t' "unexpand -a 转换所有空格序列"

# ========== -t 4 指定宽度 ==========
bb_run_stdin "a   b" unexpand -t 4
like "$_BB_STDOUT" $'\t' "unexpand -t 4 指定制表宽度"

# ========== 无空格 ==========
bb_run_stdin "nospaces" unexpand
is "$_BB_STDOUT" "nospaces" "unexpand 无空格不变"

# ========== 从文件读取 ==========
f=$(mkfile "spaces.txt" "a       b")
bb_run unexpand "$f"
like "$_BB_STDOUT" $'\t' "unexpand 从文件读取转换"

# ========== 空输入 ==========
bb_run_stdin "" unexpand
is "$_BB_STDOUT" "" "unexpand 空输入无输出"

# ========== 不足制表宽度的空格不变 ==========
bb_run_stdin "a b" unexpand -t 4
is "$_BB_STDOUT" "a b" "unexpand 不足制表宽度的空格不变"

# ========== -a -t 2 ==========
bb_run_stdin "a  b  c" unexpand -a -t 2
like "$_BB_STDOUT" $'\t' "unexpand -a -t 2 转换空格"

# ========== 行首空格转换 ==========
bb_run_stdin "    hello" unexpand
like "$_BB_STDOUT" $'\thello' "unexpand 行首空格转换"

# ========== 单空格不变 ==========
bb_run_stdin "a b c" unexpand
unlike "$_BB_STDOUT" $'\t' "unexpand 单空格不转换"

done_testing
