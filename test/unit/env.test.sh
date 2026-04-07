#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# wasmtime 默认不传环境变量，需要 bb_run_env 传入 HOME/PATH

# env 基本调用（带环境变量）
bb_run_env env
is "$_BB_EXIT" "0" "env 列出环境变量不崩溃"

# 输出非空
bb_run_env env
isnt "$_BB_STDOUT" "" "env 输出非空"

# env -i 清空环境后无输出
bb_run env -i
is "$_BB_STDOUT" "" "env -i 清空环境后无输出"

# env 输出包含 KEY=VALUE 格式
bb_run_env env
like "$_BB_STDOUT" "=" "env 输出包含等号分隔的键值"

# env VAR=val command 需要 fork+exec（WASI 不支持）
skip "env VAR=val command 需要 fork+exec（WASI ENOSYS）"

# env 设置多个变量需要 fork
skip "env 设置多个变量需要 fork（WASI ENOSYS）"

# 通过 wsh 调用
bb_run_wsh 'env'
is "$_BB_EXIT" "0" "env 在 wsh 中正常"

done_testing
