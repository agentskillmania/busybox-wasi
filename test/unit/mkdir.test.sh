#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 创建单个目录
bb_run mkdir "$TMPDIR/new_dir"
is "$_BB_EXIT" "0" "mkdir 创建单个目录成功"
cmp_ok "$(test -d "$TMPDIR/new_dir" && echo 0 || echo 1)" "==" "0" "mkdir 创建的目录确实存在"

# 创建已存在的目录应失败
bb_run mkdir "$TMPDIR/new_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "mkdir 创建已存在的目录返回非零"

# -p 创建嵌套目录
bb_run mkdir -p "$TMPDIR/nested/a/b/c"
is "$_BB_EXIT" "0" "mkdir -p 创建嵌套目录成功"
cmp_ok "$(test -d "$TMPDIR/nested/a/b/c" && echo 0 || echo 1)" "==" "0" "mkdir -p 嵌套目录确实存在"

# -p 创建已存在的目录不报错
bb_run mkdir -p "$TMPDIR/new_dir"
is "$_BB_EXIT" "0" "mkdir -p 对已存在的目录返回成功"

# 创建多级目录不带 -p 应失败
bb_run mkdir "$TMPDIR/no/parent/dir"
cmp_ok "$_BB_EXIT" "!=" "0" "mkdir 不带 -p 创建多级目录返回非零"

# 同时创建多个目录
bb_run mkdir "$TMPDIR/multi1" "$TMPDIR/multi2"
is "$_BB_EXIT" "0" "mkdir 同时创建多个目录成功"

# 空名称应失败
bb_run mkdir ""
cmp_ok "$_BB_EXIT" "!=" "0" "mkdir 空名称返回非零"

done_testing
