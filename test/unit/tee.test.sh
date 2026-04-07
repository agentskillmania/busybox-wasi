#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# ========== 基本输出到文件和 stdout ==========
outfile="$TMPDIR/tee_out.txt"
bb_run_stdin "hello world" tee "$outfile"
is "$_BB_STDOUT" "hello world" "tee stdout 输出内容正确"
# 验证文件内容
bb_run cat "$outfile"
is "$_BB_STDOUT" "hello world" "tee 文件内容正确"

# ========== 多行输入 ==========
outfile2="$TMPDIR/tee_out2.txt"
bb_run_stdin $'line1\nline2\nline3' tee "$outfile2"
bb_run cat "$outfile2"
is "$_BB_STDOUT" $'line1\nline2\nline3' "tee 多行写入文件正确"

# ========== -a 追加模式 ==========
outfile3="$TMPDIR/tee_append.txt"
printf 'existing\n' > "$outfile3"
bb_run_stdin "appended" tee -a "$outfile3"
bb_run cat "$outfile3"
like "$_BB_STDOUT" "existing" "tee -a 追加模式保留原内容"
like "$_BB_STDOUT" "appended" "tee -a 追加模式添加新内容"

# ========== 输出到多个文件 ==========
f1="$TMPDIR/tee1.txt"
f2="$TMPDIR/tee2.txt"
bb_run_stdin "multi" tee "$f1" "$f2"
bb_run cat "$f1"
is "$_BB_STDOUT" "multi" "tee 输出到第一个文件"
bb_run cat "$f2"
is "$_BB_STDOUT" "multi" "tee 输出到第二个文件"

# ========== 空输入 ==========
outfile4="$TMPDIR/tee_empty.txt"
bb_run_stdin "" tee "$outfile4"
bb_run cat "$outfile4"
is "$_BB_STDOUT" "" "tee 空输入文件为空"

# ========== 覆盖已有文件 ==========
outfile5="$TMPDIR/tee_overwrite.txt"
printf 'old content\n' > "$outfile5"
bb_run_stdin "new content" tee "$outfile5"
bb_run cat "$outfile5"
is "$_BB_STDOUT" "new content" "tee 覆盖已有文件"

done_testing
