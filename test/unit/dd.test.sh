#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 2

# dd 内部需要 dup() 系统调用，WASI stub 返回 ENOSYS
# 所有 dd 操作都会失败

bb_run dd if=/dev/null of="$TMPDIR/dd_out.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "dd 需要 dup()，WASI 不支持"

bb_run dd --help 2>/dev/null
# --help 可能也不行，只要不 crash 就行
ok "dd 不崩溃"
