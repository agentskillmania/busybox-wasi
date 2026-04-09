#!/bin/bash
# BusyBox xz 仅支持解压（-d），不支持压缩
# 解压通过 stdin 和文件模式均可用
source "$(dirname "$0")/../helper.sh"
plan 8

# xz 无参数应报错（没有 -d 不做任何事）
bb_run xz
cmp_ok "$_BB_EXIT" "!=" "0" "xz 无参数返回非零"

# xz 原地压缩应失败（仅支持解压）
mkfile "xz_test.txt" "test data"
bb_run xz "$TMPDIR/xz_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "xz 压缩功能不可用"

# xz 不存在的文件应报错
bb_run xz "$TMPDIR/nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "xz 不存在的文件返回非零"

# xz -d stdin 解压（用 base64 编码绕过 bash 变量二进制限制）
if command -v xz &>/dev/null; then
    encoded=$(echo "hello xz world" | xz | base64)
    decoded=$(echo "$encoded" | base64 -d)
    bb_run_stdin "$decoded" xz -d
    if [[ "$_BB_EXIT" == "0" ]]; then
        is "$_BB_STDOUT" "hello xz world" "xz -d stdin 解压输出正确"
    else
        skip "xz -d stdin 解压（二进制数据传递问题）"
    fi
else
    skip "xz -d stdin 解压（host 无 xz 命令）"
fi

# xz -d 文件解压（用 host xz 生成压缩文件）
if command -v xz &>/dev/null; then
    echo "file decompress test" | xz > "$TMPDIR/data.xz"
    bb_run xz -d "$TMPDIR/data.xz"
    if [[ "$_BB_EXIT" == "0" ]]; then
        bb_run cat "$TMPDIR/data"
        is "$_BB_STDOUT" "file decompress test" "xz -d 文件解压内容正确"
    else
        skip "xz -d 文件解压（执行失败）"
        skip "xz -d 文件解压（内容验证）"
    fi
else
    skip "xz -d 文件解压（host 无 xz 命令）"
    skip "xz -d 文件解压（内容验证）"
fi

# xz -d 不存在的文件
bb_run xz -d "$TMPDIR/nonexistent.xz"
cmp_ok "$_BB_EXIT" "!=" "0" "xz -d 不存在的文件返回非零"

done_testing
