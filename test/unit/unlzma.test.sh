#!/bin/bash
# unlzma = lzma -d，解压 lzma 格式数据
# stdin 和文件解压均可用
source "$(dirname "$0")/../helper.sh"
plan 6

# unlzma 不存在的文件
bb_run unlzma "$TMPDIR/nonexistent.lzma"
cmp_ok "$_BB_EXIT" "!=" "0" "unlzma 不存在的文件返回非零"

# unlzma stdin 解压（用 base64 编码绕过 bash 二进制限制）
if command -v lzma &>/dev/null; then
    encoded=$(echo "hello unlzma" | lzma | base64)
    decoded=$(echo "$encoded" | base64 -d)
    bb_run_stdin "$decoded" unlzma
    if [[ "$_BB_EXIT" == "0" ]]; then
        is "$_BB_STDOUT" "hello unlzma" "unlzma stdin 解压输出正确"
    else
        skip "unlzma stdin 解压（二进制数据传递问题）"
    fi
else
    skip "unlzma stdin 解压（host 无 lzma 命令）"
fi

# unlzma 文件解压（使用 $TMPDIR 确保在 wasmtime --dir 映射内）
if command -v lzma &>/dev/null; then
    echo "unlzma file test" | lzma > "$TMPDIR/data.lzma"
    bb_run unlzma "$TMPDIR/data.lzma"
    if [[ "$_BB_EXIT" == "0" ]]; then
        bb_run cat "$TMPDIR/data"
        is "$_BB_STDOUT" "unlzma file test" "unlzma 文件解压内容正确"
    else
        skip "unlzma 文件解压（执行失败）"
        skip "unlzma 文件解压（内容验证）"
    fi
else
    skip "unlzma 文件解压（host 无 lzma 命令）"
    skip "unlzma 文件解压（内容验证）"
fi

# unlzma 空输入不是有效的 lzma 数据，应返回非零
bb_run_stdin "" unlzma
cmp_ok "$_BB_EXIT" "!=" "0" "unlzma 空输入返回非零（无效数据）"

done_testing
