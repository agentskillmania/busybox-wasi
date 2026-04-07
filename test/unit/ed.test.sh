#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# ========== 创建测试文件 ==========
f=$(mkfile "test_ed.txt" $'line1\nline2\nline3')

# ========== 追加行 ==========
# 用 printf 通过 stdin 向 ed 发送命令
bb_run_stdin $'a\nnew line\n.\nw\nq\n' ed "$f"
# 验证文件被修改
bb_run cat "$f"
like "$_BB_STDOUT" "new line" "ed 追加行成功"

# ========== 替换文本 ==========
f2=$(mkfile "test_sub.txt" $'hello world\nfoo bar')
bb_run_stdin $',s/hello/goodbye/\nw\nq\n' ed "$f2"
bb_run cat "$f2"
like "$_BB_STDOUT" "goodbye" "ed 替换文本成功"

# ========== 删除行 ==========
f3=$(mkfile "test_del.txt" $'aaa\nbbb\nccc')
bb_run_stdin $'2d\nw\nq\n' ed "$f3"
bb_run cat "$f3"
unlike "$_BB_STDOUT" "bbb" "ed 删除行成功"

# ========== 打印行 ==========
f4=$(mkfile "test_print.txt" $'first\nsecond\nthird')
bb_run_stdin $'2p\nq\n' ed "$f4"
like "$_BB_STDOUT" "second" "ed 打印指定行"

# ========== 显示行号 ==========
f5=$(mkfile "test_num.txt" $'alpha\nbeta\ngamma')
bb_run_stdin $'2n\nq\n' ed "$f5"
like "$_BB_STDOUT" "beta" "ed 显示带行号的内容"

# ========== 创建新文件 ==========
f6=$(mkfile "new_ed.txt" "")
bb_run_stdin $'a\ninserted text\n.\nw\nq\n' ed "$f6"
bb_run cat "$f6"
like "$_BB_STDOUT" "inserted text" "ed 创建新内容成功"

# ========== 移动到最后一行 ==========
f7=$(mkfile "test_last.txt" $'one\ntwo\nthree')
bb_run_stdin $'$p\nq\n' ed "$f7"
like "$_BB_STDOUT" "three" "ed 打印最后一行"

# ========== 全局替换 ==========
f8=$(mkfile "test_global.txt" $'aaa\nbbb\naaa')
bb_run_stdin $',s/aaa/zzz/g\nw\nq\n' ed "$f8"
bb_run cat "$f8"
like "$_BB_STDOUT" "zzz" "ed 全局替换成功"
unlike "$_BB_STDOUT" "^aaa$" "ed 全局替换原文本已删除"

done_testing
