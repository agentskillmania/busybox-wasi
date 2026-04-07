#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# 准备测试数据
mkfile "original.txt" "zcat test content
second line of zcat test
third line here"
bb_run gzip "$TMPDIR/original.txt"

# zcat 读取压缩文件
bb_run zcat "$TMPDIR/original.txt.gz"
is "$_BB_EXIT" "0" "zcat 读取 gzip 文件成功"
is "$_BB_STDOUT" "zcat test content
second line of zcat test
third line here" "zcat 输出内容与原始文件一致"

# zcat 保留压缩文件
ok "[ -f $TMPDIR/original.txt.gz ]" "zcat 不删除压缩文件"

# zcat 多文件
mkfile "multi1.txt" "part one"
mkfile "multi2.txt" "part two"
bb_run gzip "$TMPDIR/multi1.txt"
bb_run gzip "$TMPDIR/multi2.txt"
bb_run zcat "$TMPDIR/multi1.txt.gz" "$TMPDIR/multi2.txt.gz"
is "$_BB_STDOUT" "part onepart two" "zcat 拼接多个压缩文件"

# zcat 不存在的文件
bb_run zcat "$TMPDIR/no_such.gz"
cmp_ok "$_BB_EXIT" "!=" "0" "zcat 不存在的文件返回非零"

# zcat 从 stdin 读取
mkfile "stdin_test.txt" "stdin zcat data"
bb_run gzip "$TMPDIR/stdin_test.txt"
bb_run_stdin "$(cat "$TMPDIR/stdin_test.txt.gz")" zcat
is "$_BB_EXIT" "0" "zcat 从 stdin 读取成功"
is "$_BB_STDOUT" "stdin zcat data" "zcat stdin 输出内容正确"

done_testing
