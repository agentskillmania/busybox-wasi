#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# nohup 在 WASI 中无法执行子进程（需要 fork+exec），
# 验证命令正确报告 WASI 限制

# nohup 无参数应报错并显示用法
bb_run_capture nohup
cmp_ok "$_BB_EXIT" "!=" "0" "nohup 无参数返回非零退出码"
like "$_BB_STDERR" "Usage" "nohup 无参数 stderr 包含用法说明"

# nohup echo — WASI 无法 exec 子进程，应报错
bb_run_capture nohup echo hello
cmp_ok "$_BB_EXIT" "!=" "0" "nohup echo 返回非零退出码"
like "$_BB_STDERR" "Function not implemented" "nohup echo stderr 包含 Function not implemented"
like "$_BB_STDERR" "can't execute" "nohup echo stderr 包含 can't execute 提示"

# nohup true — 同样无法 exec，应报错
bb_run_capture nohup true
cmp_ok "$_BB_EXIT" "!=" "0" "nohup true 返回非零退出码"
like "$_BB_STDERR" "Function not implemented" "nohup true stderr 包含 Function not implemented"

done_testing
