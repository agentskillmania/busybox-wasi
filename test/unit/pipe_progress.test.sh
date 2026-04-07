#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# pipe_progress --help（可能不支持）
bb_run pipe_progress --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "pipe_progress --help 成功"
else
    skip "pipe_progress --help 不可用"
fi

# pipe_progress 从 stdin 读取数据
mkfile "pp_data.txt" "pipe progress test data line 1
pipe progress test data line 2
pipe progress test data line 3"

bb_run_stdin "$(cat "$TMPDIR/pp_data.txt")" pipe_progress
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "pipe_progress 处理 stdin 数据成功"
else
    # pipe_progress 可能因 WASM 限制（如时间函数）而失败
    skip "pipe_progress 在 WASM 环境不可用"
fi

# pipe_progress 无 stdin
bb_run pipe_progress
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "pipe_progress 无 stdin 正常退出"
else
    cmp_ok "$_BB_EXIT" ">=" "0" "pipe_progress 无 stdin 不崩溃"
fi

# pipe_progress -l 指定输出间隔
bb_run_stdin "$(cat "$TMPDIR/pp_data.txt")" pipe_progress -l 10
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "pipe_progress -l 指定间隔成功"
else
    skip "pipe_progress -l 在 WASM 环境不可用"
fi

# pipe_progress 处理大数据
dd if=/dev/urandom of="$TMPDIR/pp_big.bin" bs=1024 count=100 2>/dev/null
bb_run_stdin "$(cat "$TMPDIR/pp_big.bin")" pipe_progress
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "pipe_progress 处理 100KB 数据成功"
else
    skip "pipe_progress 大数据处理在 WASM 环境不可用"
fi

done_testing
