#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# readlink 在 WASI 中不可用：符号链接操作不被支持（Operation not permitted）
# 所有 readlink 操作返回非零

# 创建符号链接用于测试（使用 host ln -s）
f1=$(mkfile "rl_target.txt" "readlink data")
ln -s "$f1" "$TMPDIR/rl_link" 2>/dev/null

# readlink 读取符号链接在 WASI 中不可用
bb_run readlink "$TMPDIR/rl_link"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink 在 WASI 中不可用（符号链接操作不被支持）"

# readlink -f 同样不可用
bb_run readlink -f "$TMPDIR/rl_link"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink -f 在 WASI 中不可用"

# readlink 对非符号链接应失败
bb_run readlink "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink 对非符号链接返回非零"

# readlink 不存在的路径应失败
bb_run readlink "$TMPDIR/no_such_link"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink 不存在的路径返回非零"

# 验证不是段错误
bb_run_capture readlink "$TMPDIR/rl_link"
unlike "$_BB_STDERR" "SIGSEGV|signal" "readlink 失败但不产生段错误"

# 创建嵌套符号链接测试
mkdir -p "$TMPDIR/rl_dir"
mkfile "rl_dir/deep.txt" "deep"
ln -s "$TMPDIR/rl_dir/deep.txt" "$TMPDIR/rl_dirlink" 2>/dev/null
bb_run readlink "$TMPDIR/rl_dirlink"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink 嵌套符号链接在 WASI 中不可用"

# readlink 无参数应报错
bb_run readlink
cmp_ok "$_BB_EXIT" "!=" "0" "readlink 无参数返回非零"

# readlink -e 同样不可用
bb_run readlink -e "$TMPDIR/rl_link"
cmp_ok "$_BB_EXIT" "!=" "0" "readlink -e 在 WASI 中不可用"

done_testing
