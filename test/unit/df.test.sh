#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# df 在 WASI 中无法读取 /proc/mounts，所有 df 调用均返回非零退出码
# 仅验证命令不崩溃（不 segfault），并检查输出和错误行为

# df 运行不崩溃（退出码非零是预期的）
bb_run df
cmp_ok "$_BB_EXIT" "!=" "0" "df 在 WASI 中返回非零（无法访问 /proc/mounts）"
like "$_BB_STDOUT" "Filesystem" "df 输出包含表头"

# df -h 同样返回非零
bb_run df -h
cmp_ok "$_BB_EXIT" "!=" "0" "df -h 在 WASI 中返回非零"
like "$_BB_STDOUT" "Filesystem" "df -h 输出包含表头"

# df -k 同样返回非零
bb_run df -k
cmp_ok "$_BB_EXIT" "!=" "0" "df -k 在 WASI 中返回非零"

# df 指定路径返回非零（无法找到挂载点）
bb_run df "$TMPDIR"
cmp_ok "$_BB_EXIT" "!=" "0" "df 指定路径返回非零（WASI 无法找到挂载点）"

# df 不存在的路径应失败
bb_run df "$TMPDIR/nonexistent_df_path"
cmp_ok "$_BB_EXIT" "!=" "0" "df 不存在的路径返回非零"

done_testing
