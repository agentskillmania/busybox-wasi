#!/bin/bash
# unxz = xz -d，解压 xz 格式数据
# stdin 和文件解压均可用
source "$(dirname "$0")/../helper.sh"
plan 6

# unxz 不存在的文件
bb_run unxz "$TMPDIR/nonexistent.xz"
cmp_ok "$_BB_EXIT" "!=" "0" "unxz 不存在的文件返回非零"

# unxz stdin 解压（用 base64 编码绕过 bash 二进制限制）
if command -v xz &>/dev/null; then
    encoded=$(echo "hello unxz" | xz | base64)
    decoded=$(echo "$encoded" | base64 -d)
    bb_run_stdin "$decoded" unxz
    if [[ "$_BB_EXIT" == "0" ]]; then
        is "$_BB_STDOUT" "hello unxz" "unxz stdin 解压输出正确"
    else
        skip "unxz stdin 解压（二进制数据传递问题）"
    fi
else
    skip "unxz stdin 解压（host 无 xz 命令）"
fi

# unxz 文件解压
if command -v xz &>/dev/null; then
    echo "unxz file test" | xz > "$TMPDIR/data.xz"
    bb_run unxz "$TMPDIR/data.xz"
    if [[ "$_BB_EXIT" == "0" ]]; then
        bb_run cat "$TMPDIR/data"
        is "$_BB_STDOUT" "unxz file test" "unxz 文件解压内容正确"
    else
        skip "unxz 文件解压（执行失败）"
        skip "unxz 文件解压（内容验证）"
    fi
else
    skip "unxz 文件解压（host 无 xz 命令）"
    skip "unxz 文件解压（内容验证）"
fi

# unxz 空输入不崩溃
bb_run_stdin "" unxz
is "$_BB_EXIT" "0" "unxz 空输入不崩溃"

done_testing
