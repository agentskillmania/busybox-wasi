#!/bin/bash
# chmod 在 WASI 下因 chmod() 系统调用返回 ENOSYS 而全部失败
# 测试目标：验证 chmod 在各种场景下正确返回错误而非崩溃
source "$(dirname "$0")/../helper.sh"
plan 10

# 生成测试文件
f1=$(mkfile "chmod_file.txt" "permission data")

# 数字模式修改权限 — WASI 下应返回非零
bb_run chmod 644 "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod 644 在 WASI 下返回非零（ENOSYS）"

# 符号模式修改权限 — WASI 下应返回非零
bb_run chmod +x "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod +x 在 WASI 下返回非零"

# 减少权限 — WASI 下应返回非零
bb_run chmod -x "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod -x 在 WASI 下返回非零"

# 递归修改目录权限 — WASI 下应返回非零
mkdir -p "$TMPDIR/chmod_dir/sub"
mkfile "chmod_dir/f.txt" "rec"
mkfile "chmod_dir/sub/g.txt" "rec2"
bb_run chmod -R 755 "$TMPDIR/chmod_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod -R 在 WASI 下返回非零"

# 对不存在的文件应失败（这是正常行为，与 WASI 无关）
bb_run chmod 644 "$TMPDIR/nonexistent_chmod.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod 对不存在的文件返回非零"

# 无参数应失败
bb_run chmod
cmp_ok "$_BB_EXIT" "!=" "0" "chmod 无参数返回非零"

# 缺少模式应失败
bb_run chmod "$f1"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod 缺少模式返回非零"

# 多文件修改权限 — WASI 下应返回非零
mkfile "chmod_m1.txt" "a"
mkfile "chmod_m2.txt" "b"
bb_run chmod 600 "$TMPDIR/chmod_m1.txt" "$TMPDIR/chmod_m2.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod 同时修改多个文件在 WASI 下返回非零"

# 对目录修改权限 — WASI 下应返回非零
mkdir -p "$TMPDIR/chmod_only_dir"
bb_run chmod 755 "$TMPDIR/chmod_only_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "chmod 修改目录权限在 WASI 下返回非零"

# chmod --help 应正常工作（不依赖系统调用）
bb_run chmod --help
cmp_ok "$_BB_EXIT" "==" "0" "chmod --help 正常输出"

done_testing
