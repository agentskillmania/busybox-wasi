#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# ========== 基本拷贝 ==========
f=$(mkfile "input.txt" "Hello from dd")
bb_run dd "if=$TMPDIR/input.txt" "of=$TMPDIR/output.txt" 2>/dev/null
is "$_BB_EXIT" "0" "dd 基本拷贝成功退出码 0"
bb_run cat "$TMPDIR/output.txt"
is "$_BB_STDOUT" "Hello from dd" "dd 拷贝内容正确"

# ========== skip/seek ==========
bb_run dd "if=$TMPDIR/input.txt" "of=$TMPDIR/skip_out.txt" bs=1 skip=6 2>/dev/null
is "$_BB_EXIT" "0" "dd skip=6 成功"
bb_run cat "$TMPDIR/skip_out.txt"
is "$_BB_STDOUT" "from dd" "dd skip=6 内容正确"

# ========== bs + count 参数 ==========
f2=$(mkfile "bs_input.txt" "ABCDEFGHIJ")
bb_run dd "if=$TMPDIR/bs_input.txt" "of=$TMPDIR/bs_output.txt" bs=3 count=2 2>/dev/null
is "$_BB_EXIT" "0" "dd bs=3 count=2 成功"
bb_run cat "$TMPDIR/bs_output.txt"
is "$_BB_STDOUT" "ABCDEF" "dd bs=3 count=2 内容正确"

done_testing
