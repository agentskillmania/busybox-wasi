#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 创建新文件
bb_run touch "$TMPDIR/touch_new.txt"
is "$_BB_EXIT" "0" "touch 创建新文件成功"
cmp_ok "$(test -f "$TMPDIR/touch_new.txt" && echo 0 || echo 1)" "==" "0" "touch 创建的文件确实存在"

# 更新已有文件的时间戳
f1=$(mkfile "touch_exist.txt" "already here")
bb_run touch "$f1"
is "$_BB_EXIT" "0" "touch 更新已有文件时间戳成功"
bb_run cat "$f1"
is "$_BB_STDOUT" "already here" "touch 不改变文件内容"

# -c 不创建新文件
bb_run touch -c "$TMPDIR/touch_nocreate.txt"
is "$_BB_EXIT" "0" "touch -c 不创建文件返回成功"
cmp_ok "$(test -f "$TMPDIR/touch_nocreate.txt" && echo 1 || echo 0)" "==" "0" "touch -c 确实没有创建文件"

# -c 对已有文件正常
bb_run touch -c "$f1"
is "$_BB_EXIT" "0" "touch -c 对已有文件返回成功"

# -t 设置指定时间戳
bb_run touch -t 202301011200 "$TMPDIR/touch_time.txt"
is "$_BB_EXIT" "0" "touch -t 设置时间戳成功"
cmp_ok "$(test -f "$TMPDIR/touch_time.txt" && echo 0 || echo 1)" "==" "0" "touch -t 创建的文件存在"

# 同时 touch 多个文件
bb_run touch "$TMPDIR/touch_a.txt" "$TMPDIR/touch_b.txt" "$TMPDIR/touch_c.txt"
is "$_BB_EXIT" "0" "touch 同时创建多个文件成功"

# touch 无参数应失败
bb_run touch
cmp_ok "$_BB_EXIT" "!=" "0" "touch 无参数返回非零"

done_testing
