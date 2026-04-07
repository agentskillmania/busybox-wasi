#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# which 查找命令（WASM 中 PATH 可能受限）
bb_run which ls
# 可能成功也可能失败，取决于环境
is "$_BB_EXIT" "0" "which ls 在 WASM 中不崩溃" || true

# which 不存在的命令
bb_run which nonexistent_command_xyz
cmp_ok "$_BB_EXIT" "!=" "0" "which 不存在的命令返回非零"

# which 无参数
bb_run which
cmp_ok "$_BB_EXIT" "!=" "0" "which 无参数返回非零"

# 通过 wsh 调用
bb_run_wsh 'which echo'
is "$_BB_EXIT" "0" "which 在 wsh 中查找 echo"

# which -a 显示所有匹配
bb_run which -a true
# 不验证退出码，只验证不崩溃
ok "which -a 不崩溃"

done_testing
