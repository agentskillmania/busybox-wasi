#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# mkfifo 创建命名管道（WASI 中 mknod 可能返回 ENOSYS）
bb_run mkfifo "$TMPDIR/test_fifo"
_mkfifo_failed="0"
[[ "$_BB_EXIT" != "0" ]] && _mkfifo_failed="1"

if skip_if "$_mkfifo_failed" "mkfifo 在 WASI 中不可用（mknod ENOSYS）"; then
    # 如果跳过了，后续测试也跳过
    skip "mkfifo -m 设置权限在 WASI 中不可用"
    skip "mkfifo 已存在文件在 WASI 中不可用"
    skip "mkfifo 管道类型验证在 WASI 中不可用"
    skip "mkfifo 无参数在 WASI 中不可用"
else
    is "$_BB_EXIT" "0" "mkfifo 创建命名管道成功"

    # 验证是否为 FIFO 类型
    bb_run test -p "$TMPDIR/test_fifo"
    is "$_BB_EXIT" "0" "mkfifo 创建的文件是 FIFO 类型"

    # mkfifo -m 设置权限
    bb_run mkfifo -m 644 "$TMPDIR/fifo_perm"
    is "$_BB_EXIT" "0" "mkfifo -m 设置权限成功"

    # mkfifo 已存在文件应失败
    mkfile "existing_fifo.txt" "data"
    bb_run mkfifo "$TMPDIR/existing_fifo.txt"
    cmp_ok "$_BB_EXIT" "!=" "0" "mkfifo 目标已存在返回非零"

    # mkfifo 无参数应失败
    bb_run mkfifo
    cmp_ok "$_BB_EXIT" "!=" "0" "mkfifo 无参数返回非零"
fi

done_testing
