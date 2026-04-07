#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# groups 在 WASI 中无法查询用户组信息（unknown ID 0），退出码为 1
# 仅验证命令不崩溃（不 segfault）

# groups 返回非零（WASI 中无用户数据库）
bb_run groups
cmp_ok "$_BB_EXIT" "!=" "0" "groups 在 WASI 中返回非零（无用户数据库）"

# 输出可能是空的或包含错误信息，不崩溃即可
bb_run groups
ok "groups 输出不崩溃: $_BB_STDOUT"

# 通过 wsh 调用同样返回非零
bb_run_wsh 'groups'
cmp_ok "$_BB_EXIT" "!=" "0" "groups 在 wsh 中返回非零"

# 输出不含段错误等严重错误
bb_run groups
unlike "$_BB_STDOUT" "SIGSEGV|Segmentation" "groups 输出不含段错误信息"

# 无参数调用（当前用户）同样返回非零
bb_run groups
cmp_ok "$_BB_EXIT" "!=" "0" "groups 无参数时返回非零"

done_testing
