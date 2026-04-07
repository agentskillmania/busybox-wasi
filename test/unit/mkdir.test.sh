#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# mkdir 在 WASI 中：基本创建正常，mkdir -p 不可用（尝试创建 '/' 失败）

# 创建单个目录
bb_run mkdir "$TMPDIR/new_dir"
is "$_BB_EXIT" "0" "mkdir 创建单个目录成功"
cmp_ok "$(test -d "$TMPDIR/new_dir" && echo 0 || echo 1)" "==" "0" "mkdir 创建的目录确实存在"

# 创建已存在的目录应失败
bb_run mkdir "$TMPDIR/new_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "mkdir 创建已存在的目录返回非零"

# mkdir -p 在 WASI 中不可用（尝试递归创建 '/' 路径时报错）
bb_run mkdir -p "$TMPDIR/nested/a/b/c"
cmp_ok "$_BB_EXIT" "!=" "0" "mkdir -p 在 WASI 中不可用（无法创建 '/' 路径）"

# mkdir -p 对已存在的目录同样不可用
bb_run mkdir -p "$TMPDIR/new_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "mkdir -p 对已存在目录在 WASI 中也返回非零"

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
