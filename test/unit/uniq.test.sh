#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 11

# ========== 基本去重（已排序输入）==========
bb_run_stdin $'a\na\nb\nb\nc' uniq
is "$_BB_STDOUT" $'a\nb\nc' "uniq 基本去重"

# ========== -c 计数 ==========
bb_run_stdin $'a\na\na\nb\nb' uniq -c
like "$_BB_STDOUT" "3.*a" "uniq -c 显示重复次数 3"
like "$_BB_STDOUT" "2.*b" "uniq -c 显示重复次数 2"

# ========== -d 只显示重复行 ==========
bb_run_stdin $'a\na\nb\nc\nc' uniq -d
is "$_BB_STDOUT" $'a\nc' "uniq -d 只显示重复行"

# ========== -u 只显示不重复行 ==========
bb_run_stdin $'a\na\nb\nc\nc' uniq -u
is "$_BB_STDOUT" "b" "uniq -u 只显示不重复行"

# ========== 无重复输入 ==========
bb_run_stdin $'a\nb\nc' uniq
is "$_BB_STDOUT" $'a\nb\nc' "uniq 无重复输入不变"

# ========== 从文件读取 ==========
f=$(mkfile "data.txt" $'x\nx\ny\nz')
bb_run uniq "$f"
is "$_BB_STDOUT" $'x\ny\nz' "uniq 从文件读取"

# ========== 空输入 ==========
bb_run_stdin "" uniq
is "$_BB_STDOUT" "" "uniq 空输入无输出"

# ========== 单行输入 ==========
bb_run_stdin "only" uniq
is "$_BB_STDOUT" "only" "uniq 单行输入不变"

# ========== -d 无重复行时 ==========
bb_run_stdin $'a\nb\nc' uniq -d
is "$_BB_STDOUT" "" "uniq -d 无重复行时无输出"

# ========== 连续相同检测 ==========
bb_run_stdin $'a\nb\na' uniq
is "$_BB_STDOUT" $'a\nb\na' "uniq 只去除连续重复（非全局去重）"

done_testing
