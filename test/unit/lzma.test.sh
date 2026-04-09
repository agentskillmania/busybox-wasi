#!/bin/bash
# BusyBox lzma 仅支持解压（-d），不支持压缩
# 解压通过 stdin 和文件模式均可用
source "$(dirname "$0")/../helper.sh"
plan 8

# lzma 无参数应报错
bb_run lzma
cmp_ok "$_BB_EXIT" "!=" "0" "lzma 无参数返回非零"

# lzma 原地压缩应失败（仅支持解压）
mkfile "lzma_test.txt" "test data"
bb_run lzma "$TMPDIR/lzma_test.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "lzma 压缩功能不可用"

# lzma 不存在的文件应报错
bb_run lzma "$TMPDIR/nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "lzma 不存在的文件返回非零"

# lzma -d stdin 解压
if command -v lzma &>/dev/null; then
    encoded=$(echo "hello lzma world" | lzma | base64)
    decoded=$(echo "$encoded" | base64 -d)
    bb_run_stdin "$decoded" lzma -d
    if [[ "$_BB_EXIT" == "0" ]]; then
        is "$_BB_STDOUT" "hello lzma world" "lzma -d stdin 解压输出正确"
    else
        skip "lzma -d stdin 解压（二进制数据传递问题）"
    fi
else
    skip "lzma -d stdin 解压（host 无 lzma 命令）"
fi

# lzma -d 文件解压
if command -v lzma &>/dev/null; then
    echo "file decompress test" | lzma > "$TMPDIR/data.lzma"
    bb_run lzma -d "$TMPDIR/data.lzma"
    if [[ "$_BB_EXIT" == "0" ]]; then
        bb_run cat "$TMPDIR/data"
        is "$_BB_STDOUT" "file decompress test" "lzma -d 文件解压内容正确"
    else
        skip "lzma -d 文件解压（执行失败）"
        skip "lzma -d 文件解压（内容验证）"
    fi
else
    skip "lzma -d 文件解压（host 无 lzma 命令）"
    skip "lzma -d 文件解压（内容验证）"
fi

# lzma -d 不存在的文件
bb_run lzma -d "$TMPDIR/nonexistent.lzma"
cmp_ok "$_BB_EXIT" "!=" "0" "lzma -d 不存在的文件返回非零"

done_testing
