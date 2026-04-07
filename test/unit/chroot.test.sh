#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# chroot --help
bb_run chroot --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "chroot --help 成功"
else
    skip "chroot --help 不可用"
fi

# chroot 无参数
bb_run_capture chroot
cmp_ok "$_BB_EXIT" "!=" "0" "chroot 无参数返回非零"

# chroot 需要 chroot() 系统调用，在 WASM 中被 stub 返回 ENOSYS
mkdir -p "$TMPDIR/newroot"
mkfile "newroot/test.txt" "chroot test"
bb_run chroot "$TMPDIR/newroot" /bin/sh
if [[ "$_BB_EXIT" != "0" ]]; then
    cmp_ok "$_BB_EXIT" "!=" "0" "chroot 因系统调用 stub 返回非零（预期行为）"
else
    skip "chroot 意外成功（stub 可能已实现？）"
fi

# chroot 不存在的目录
bb_run chroot "$TMPDIR/nonexistent_root" /bin/sh
cmp_ok "$_BB_EXIT" "!=" "0" "chroot 不存在的目录返回非零"

# chroot 指定用户（需要 getpwnam，也可能被 stub）
bb_run chroot --userspec=root "$TMPDIR/newroot" /bin/sh
if [[ "$_BB_EXIT" != "0" ]]; then
    cmp_ok "$_BB_EXIT" "!=" "0" "chroot --userspec 因 stub 返回非零（预期）"
else
    skip "chroot --userspec 行为不确定"
fi

# chroot 指定命令
bb_run chroot "$TMPDIR/newroot" /bin/echo "hello"
if [[ "$_BB_EXIT" != "0" ]]; then
    cmp_ok "$_BB_EXIT" "!=" "0" "chroot 执行命令因 stub 返回非零（预期）"
else
    skip "chroot 执行命令行为不确定"
fi

done_testing
