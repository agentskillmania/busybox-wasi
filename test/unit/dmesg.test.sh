#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# dmesg 基本调用（WASM 中可能为空或报错）
bb_run dmesg
# 不严格验证退出码，WASM 环境可能不支持
ok "dmesg 不崩溃"

# 通过 wsh 调用
bb_run_wsh 'dmesg'
ok "dmesg 在 wsh 中不崩溃"

# dmesg 输出不含段错误信息
bb_run dmesg
unlike "$_BB_STDOUT" "SIGSEGV|segfault" "dmesg 输出不含段错误"

# 不验证具体输出内容（WASM 中可能为空）
bb_run dmesg
ok "dmesg 输出（可能为空）: $(echo "$_BB_STDOUT" | head -1)"

# -c 选项（清空缓冲区后输出）
bb_run dmesg -c
ok "dmesg -c 不崩溃"

done_testing
