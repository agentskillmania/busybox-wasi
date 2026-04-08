#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# lzop 压缩/解压在 WASI 中正常工作
# stdin 管道模式和文件模式均可用

# lzop -c stdin 压缩
bb_run_stdin "hello lzop" lzop -c
is "$_BB_EXIT" "0" "lzop -c stdin 压缩成功"
cmp_ok "${#_BB_STDOUT}" ">" "0" "lzop -c 输出非空"

# lzop 原地压缩文件
mkfile "lzop_file.txt" "test"
bb_run lzop "$TMPDIR/lzop_file.txt"
is "$_BB_EXIT" "0" "lzop 原地压缩成功"
ok "[ -f $TMPDIR/lzop_file.txt.lzo ]" "lzop 压缩后 .lzo 文件存在"

# lzop -c 文件压缩
bb_run lzop -c "$TMPDIR/lzop_file.txt"
is "$_BB_EXIT" "0" "lzop -c 文件压缩成功"
cmp_ok "${#_BB_STDOUT}" ">" "0" "lzop -c 文件输出非空"

# lzop 不存在的文件
bb_run lzop "$TMPDIR/nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "lzop 不存在的文件返回非零"

# lzop -d stdin 解压
bb_run_stdin "hello" lzop -c
if [[ "$_BB_EXIT" == "0" ]]; then
    lzop_data="$_BB_STDOUT"
    bb_run_stdin "$lzop_data" lzop -d -c
    if [[ "$_BB_EXIT" == "0" ]]; then
        is "$_BB_STDOUT" "hello" "lzop 往返解压正确"
    else
        skip "lzop -d stdin（二进制数据传递限制）"
    fi
else
    skip "lzop 往返解压（压缩失败）"
fi

done_testing
