#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# mkfifo 在 WASI 中不可用（mknod 返回 ENOSYS：Function not implemented）
# 所有 mkfifo 操作均跳过

# mkfifo 基本调用在 WASI 中不可用
bb_run mkfifo "$TMPDIR/test_fifo"
cmp_ok "$_BB_EXIT" "!=" "0" "mkfifo 在 WASI 中不可用（mknod ENOSYS）"

# 验证不是段错误等严重错误（只是 ENOSYS）
bb_run_capture mkfifo "$TMPDIR/test_fifo"
unlike "$_BB_STDERR" "SIGSEGV|signal" "mkfifo 失败但不产生段错误"

# mkfifo -m 设置权限同样不可用
bb_run mkfifo -m 644 "$TMPDIR/fifo_perm"
cmp_ok "$_BB_EXIT" "!=" "0" "mkfifo -m 在 WASI 中不可用"

# mkfifo 已存在文件应返回错误（不是因为 ENOSYS 而是因为文件已存在）
mkfile "existing_fifo.txt" "data"
bb_run mkfifo "$TMPDIR/existing_fifo.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "mkfifo 目标已存在返回非零"

# mkfifo 无参数应报错
bb_run mkfifo
cmp_ok "$_BB_EXIT" "!=" "0" "mkfifo 无参数返回非零"

# mkfifo 在 wsh 中同样不可用
bb_run_wsh 'mkfifo /tmp/test_wsh_fifo'
cmp_ok "$_BB_EXIT" "!=" "0" "mkfifo 在 wsh 中同样不可用"

done_testing
