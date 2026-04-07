#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 11

# ========== 基本制表符转空格 ==========
bb_run_stdin $'hello\tworld' expand
like "$_BB_STDOUT" "^hello   " "expand 制表符转空格"

# ========== -t 4 指定制表宽度 ==========
bb_run_stdin $'a\tb' expand -t 4
is "$_BB_STDOUT" "a   b" "expand -t 4 制表符转为 3 个空格"

# ========== 多个制表符 ==========
bb_run_stdin $'\t\t\t' expand -t 4
# 3 个 tab，每个 tab 在 -t 4 下转为 4 个空格 = 12 个空格
is "$_BB_STDOUT" "            " "expand 多个制表符全部转换"

# ========== 无制表符 ==========
bb_run_stdin "no tabs here" expand
is "$_BB_STDOUT" "no tabs here" "expand 无制表符不变"

# ========== 从文件读取 ==========
f=$(mkfile "tabs.txt" $'col1\tcol2\tcol3')
bb_run expand "$f"
unlike "$_BB_STDOUT" $'\t' "expand 文件中制表符全部转换"

# ========== 空输入 ==========
bb_run_stdin "" expand
is "$_BB_STDOUT" "" "expand 空输入无输出"

# ========== -t 8 默认宽度 ==========
bb_run_stdin $'a\tb' expand -t 8
# a 占 1 个位置，制表符补到 8，即 7 个空格
like "$_BB_STDOUT" "^a +b$" "expand -t 8 默认宽度"

# ========== 混合内容 ==========
bb_run_stdin $'x\ty\tz' expand -t 2
is "$_BB_STDOUT" "x y z" "expand -t 2 混合内容转换"

# ========== 行首制表符 ==========
bb_run_stdin $'\thello' expand -t 4
is "$_BB_STDOUT" "    hello" "expand 行首制表符转换"

# ========== 仅空格无转换 ==========
bb_run_stdin "   spaces" expand
is "$_BB_STDOUT" "   spaces" "expand 空格不受影响"

# ========== -t 1 最小宽度 ==========
bb_run_stdin $'a\tb' expand -t 1
# -t 1 时 tab 宽度 1，但 a 已占 1 列，tab 补 0 个空格 + 分隔 = "a b"
like "$_BB_STDOUT" "a.*b" "expand -t 1 最小宽度"

done_testing
