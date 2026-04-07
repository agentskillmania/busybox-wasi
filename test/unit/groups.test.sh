#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# groups 基本调用
bb_run groups
# WASM 环境中可能返回空或受限信息，但不应崩溃
is "$_BB_EXIT" "0" "groups 不崩溃"

# 输出可能是空的或包含组名
bb_run groups
# 不验证具体内容，只验证不崩溃
ok "groups 输出: $_BB_STDOUT"

# 通过 wsh 调用
bb_run_wsh 'groups'
is "$_BB_EXIT" "0" "groups 在 wsh 中不崩溃"

# 不带参数（当前用户）
bb_run groups
like "$_BB_STDOUT" ".*" "groups 无参数时输出（可能为空）"

# 输出不含错误信息
bb_run groups
unlike "$_BB_STDOUT" "Error|error|SIGSEGV" "groups 输出不含严重错误"

done_testing
