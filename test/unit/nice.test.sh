#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# nice 在 WASI 中无法执行子进程（需要 fork+exec），
# 验证命令正确报告 WASI 限制

# nice 无参数 — 查询当前优先级，不需要 exec，应正常返回
bb_run nice
is "$_BB_EXIT" "0" "nice 无参数返回 0"
is "$_BB_STDOUT" "0" "nice 无参数输出当前优先级 0"

# nice echo — WASI 无法 exec 子进程，应报错
bb_run_capture nice echo hello
cmp_ok "$_BB_EXIT" "!=" "0" "nice echo 返回非零退出码"
like "$_BB_STDERR" "Function not implemented" "nice echo stderr 包含 Function not implemented"
like "$_BB_STDERR" "can't execute" "nice echo stderr 包含 can't execute 提示"

# nice -n 10 echo — 带 -n 参数同样无法 exec，应报错
bb_run_capture nice -n 10 echo hello
cmp_ok "$_BB_EXIT" "!=" "0" "nice -n 10 echo 返回非零退出码"
like "$_BB_STDERR" "Function not implemented" "nice -n 10 echo stderr 包含 Function not implemented"

# nice true — WASI 无法 exec，应报错
bb_run_capture nice true
cmp_ok "$_BB_EXIT" "!=" "0" "nice true 返回非零退出码"
like "$_BB_STDERR" "Function not implemented" "nice true stderr 包含 Function not implemented"

done_testing
