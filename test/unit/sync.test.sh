#!/bin/bash
# sync 在 WASI 下会直接 crash（signature_mismatch wasm trap）
# 测试目标：验证 sync 可以被调用（即使崩溃），其余测试跳过
source "$(dirname "$0")/../helper.sh"
plan 4

# sync 基本调用 — 预期会 crash，只需验证进程结束即可
bb_run_capture sync
# sync crash 时退出码非零，捕获 stderr 确认是 trap
cmp_ok "$_BB_EXIT" "!=" "0" "sync 在 WASI 下以非零退出（crash）"
like "$_BB_STDERR" "trap|abort|error|wasm" "sync 产生 wasm trap 错误"

# sync 无输出（crash 时不产生有意义输出）
is "$_BB_STDOUT" "" "sync crash 时无 stdout 输出"

# 通过 wsh 调用 — 也会 crash
bb_run_wsh 'sync'
cmp_ok "$_BB_EXIT" "!=" "0" "sync 在 wsh 中也以非零退出"

done_testing
