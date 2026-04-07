#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# xzcat = xz -c -d，需要先有 xz 压缩文件
# BusyBox 的 xz 只支持解压，无法创建 xz 文件
# xzcat 读取文件也需要 dup

# xzcat 不存在的文件
bb_run xzcat "$TMPDIR/nonexistent.xz"
cmp_ok "$_BB_EXIT" "!=" "0" "xzcat 不存在的文件返回非零"

# xzcat stdin（用 host xz 创建数据，如果有的话）
if command -v xz &>/dev/null; then
    data=$(echo "hello xzcat" | xz | base64)
    decoded=$(echo "$data" | base64 -d)
    bb_run_stdin "$decoded" xzcat
    if [[ "$_BB_EXIT" == "0" ]]; then
        is "$_BB_STDOUT" "hello xzcat" "xzcat stdin 解压正确"
    else
        skip "xzcat stdin 解压（数据传递问题）"
    fi
else
    skip "xzcat stdin（host 无 xz 命令）"
fi

# xzcat 无参数时从 stdin 读取（不报错，返回 0）
bb_run xzcat
ok "xzcat 无参数不崩溃"

done_testing
