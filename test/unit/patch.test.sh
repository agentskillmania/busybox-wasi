#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# ========== 准备原始文件 ==========
f1=$(mkfile "a.txt" "hello world")
f2=$(mkfile "b.txt" "hello earth")

# ========== 创建差异 ==========
bb_run diff "$f1" "$f2"
is "$_BB_EXIT" "1" "patch diff 检测差异退出码 1"
like "$_BB_STDOUT" "earth" "patch diff 输出包含修改内容"

# ========== 创建统一格式补丁 ==========
bb_run diff -u "$f1" "$f2"
is "$_BB_EXIT" "1" "patch diff -u 检测差异退出码 1"
patch_content="$_BB_STDOUT"

# ========== 验证 diff -u 格式头 ==========
like "$_BB_STDOUT" "^---" "patch diff -u 包含 --- 头"
# +++ 可能在第二行，不要用 ^ 锚定
like "$_BB_STDOUT" "[+][+][+]" "patch diff -u 包含 +++ 头"

# ========== --dry-run 需要 /dev/null（WASI 中不存在）==========
skip "patch --dry-run 需要 /dev/null（WASI 限制）"

# ========== 相同文件无差异 ==========
f3=$(mkfile "c.txt" "same content")
f4=$(mkfile "d.txt" "same content")
bb_run diff "$f3" "$f4"
is "$_BB_EXIT" "0" "patch 相同文件无差异退出码 0"

done_testing
