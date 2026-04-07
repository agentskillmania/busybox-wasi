#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 11

# 空输入
bb_run_stdin "" cat
is "$_BB_EXIT" "0" "cat 空输入返回 0"

# 文件内容
f1=$(mkfile "hello.txt" "hello world")
bb_run cat "$f1"
is "$_BB_STDOUT" "hello world" "cat 读取文件内容"

# 多文件拼接
f2=$(mkfile "second.txt" "second")
bb_run cat "$f1" "$f2"
is "$_BB_STDOUT" "hello worldsecond" "cat 拼接多文件"

# -n 行号
bb_run cat -n "$f2"
like "$_BB_STDOUT" "1.+second" "cat -n 显示行号"

# -b 非空行编号
mkfile "mixed.txt" $'hello\n\nworld'
bb_run cat -b "$TMPDIR/mixed.txt"
like "$_BB_STDOUT" "1.+hello" "cat -b 非空行编号"
like "$_BB_STDOUT" "2.+world" "cat -b 跳过空行"

# stdin 读取
bb_run_stdin "from stdin" cat
is "$_BB_STDOUT" "from stdin" "cat 从 stdin 读取"

# 不存在的文件
bb_run cat "$TMPDIR/nope.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "cat 不存在的文件返回非零"

# 大文件
dd if=/dev/urandom of="$TMPDIR/big.bin" bs=1024 count=1024 2>/dev/null
bb_run cat "$TMPDIR/big.bin"
cmp_ok "$_BB_EXIT" "==" "0" "cat 处理 1MB 文件"

# -A 显示不可见字符
mkfile "tabs.txt" $'a\tb'
bb_run cat -A "$TMPDIR/tabs.txt"
like "$_BB_STDOUT" 'a\^Ib' "cat -A 显示 tab 为 ^I"

# 空文件
mkfile "empty.txt" ""
bb_run cat "$TMPDIR/empty.txt"
is "$_BB_STDOUT" "" "cat 空文件输出为空"

done_testing
