#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# timeout 在 WASI 中不可用（需要 vfork，WASI 不支持进程创建）
# 所有 timeout 操作返回非零退出码

# timeout 运行快速命令在 WASI 中失败
bb_run timeout 5 true
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 在 WASI 中不可用（vfork ENOSYS）"

# timeout 超时在 WASI 中同样失败
bb_run timeout 0.1 sleep 10
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 超时在 WASI 中不可用"

# timeout 0 秒同样失败
bb_run timeout 0 true
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 0 在 WASI 中不可用"

# timeout 无参数应报错（不是因为 vfork，而是参数不足）
bb_run timeout
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 无参数返回非零"

# 通过 wsh 调用 timeout 同样不可用
bb_run_wsh 'timeout 5 true'
cmp_ok "$_BB_EXIT" "!=" "0" "timeout 在 wsh 中不可用"

# timeout 带 -s 信号同样不可用
bb_run timeout -s TERM 5 true
cmp_ok "$_BB_EXIT" "!=" "0" "timeout -s TERM 在 WASI 中不可用"

# 验证不是段错误
bb_run_capture timeout 5 true
unlike "$_BB_STDERR" "SIGSEGV|signal" "timeout 失败但不产生段错误"

done_testing
