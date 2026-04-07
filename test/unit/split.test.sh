#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 11

# ========== 准备测试数据 ==========
f=$(mkfile "data.txt" $'line1\nline2\nline3\nline4\nline5\nline6')

# ========== -l 按行数分割 ==========
# split 默认输出 xaa 到 CWD，WASI 中 CWD 不在 --dir 范围内，
# 所以必须指定带 $TMPDIR 前缀的输出路径
bb_run split -l 2 "$f" "$TMPDIR/x"
is "$_BB_EXIT" "0" "split -l 2 成功退出码 0"

# 验证生成了 xaa, xab, xac 文件
bb_run cat "$TMPDIR/xaa"
is "$_BB_STDOUT" $'line1\nline2' "split 第一个分割文件内容正确"

bb_run cat "$TMPDIR/xab"
is "$_BB_STDOUT" $'line3\nline4' "split 第二个分割文件内容正确"

bb_run cat "$TMPDIR/xac"
is "$_BB_STDOUT" $'line5\nline6' "split 第三个分割文件内容正确"

# ========== -l 1 每行一个文件 ==========
f2=$(mkfile "lines.txt" $'a\nb\nc')
bb_run split -l 1 "$f2" "$TMPDIR/y"
bb_run test -f "$TMPDIR/yaa"
is "$_BB_EXIT" "0" "split -l 1 生成文件 yaa 存在"
bb_run test -f "$TMPDIR/yab"
is "$_BB_EXIT" "0" "split -l 1 生成文件 yab 存在"
bb_run test -f "$TMPDIR/yac"
is "$_BB_EXIT" "0" "split -l 1 生成文件 yac 存在"

# ========== 空文件 ==========
f3=$(mkfile "empty.txt" "")
bb_run split -l 10 "$f3" "$TMPDIR/e"
is "$_BB_EXIT" "0" "split 空文件成功退出码 0"

# ========== 行数少于分割大小 ==========
f4=$(mkfile "small.txt" $'only\none')
bb_run split -l 100 "$f4" "$TMPDIR/s"
bb_run cat "$TMPDIR/saa"
like "$_BB_STDOUT" "only" "split 行数少于分割大小生成单个文件"

# ========== 带前缀 ==========
f5=$(mkfile "prefix.txt" $'a\nb\nc\nd')
bb_run split -l 2 "$f5" "$TMPDIR/myprefix_"
bb_run test -f "$TMPDIR/myprefix_aa"
is "$_BB_EXIT" "0" "split 自定义前缀文件存在"

bb_run test -f "$TMPDIR/myprefix_ab"
is "$_BB_EXIT" "0" "split 自定义前缀第二个文件存在"

done_testing
