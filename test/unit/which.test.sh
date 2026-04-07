#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# which 在 WASI 中不可用（没有 PATH 指向有效的可执行文件目录）
# 默认 wasmtime 环境无 PATH 设置，which 无法查找命令

# which ls 在默认 WASI 环境中无法找到（无 PATH）
bb_run which ls
cmp_ok "$_BB_EXIT" "!=" "0" "which ls 在默认 WASI 环境中返回非零（无 PATH）"

# which 不存在的命令返回非零
bb_run which nonexistent_command_xyz
cmp_ok "$_BB_EXIT" "!=" "0" "which 不存在的命令返回非零"

# which 无参数返回非零
bb_run which
cmp_ok "$_BB_EXIT" "!=" "0" "which 无参数返回非零"

# 通过 wsh 调用 which 同样返回非零（无 PATH）
bb_run_wsh 'which echo'
cmp_ok "$_BB_EXIT" "!=" "0" "which 在 wsh 中返回非零（无 PATH）"

# which -a 同样返回非零
bb_run which -a true
cmp_ok "$_BB_EXIT" "!=" "0" "which -a 在 WASI 环境中返回非零"

done_testing
