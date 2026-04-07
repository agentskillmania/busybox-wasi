#!/bin/bash
# install 在 WASI 下因依赖 chmod() 而失败
# mkdir 在 WASI 下可用但 mkdir -p 有路径解析问题
# 文件复制可以成功但后续 chmod 报 ENOSYS 导致非零退出
# 测试目标：验证 install 各场景在 WASI 下的行为
source "$(dirname "$0")/../helper.sh"
plan 10

# install -d 创建目录 — 内部使用 mkdir -p，WASI 路径解析问题导致失败
bb_run install -d "$TMPDIR/inst_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "install -d 在 WASI 下返回非零（mkdir -p 路径问题）"

# install -d 创建嵌套目录 — 同样会失败
bb_run install -d "$TMPDIR/inst_deep/a/b"
cmp_ok "$_BB_EXIT" "!=" "0" "install -d 创建嵌套目录在 WASI 下返回非零"

# install 复制文件 — 文件被复制但 chmod 失败导致非零退出
mkfile "inst_src.txt" "install content"
bb_run install "$TMPDIR/inst_src.txt" "$TMPDIR/inst_dst.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "install 复制文件因 chmod 返回非零"

# 验证文件内容确实被复制了（即使 chmod 失败）
bb_run cat "$TMPDIR/inst_dst.txt"
is "$_BB_STDOUT" "install content" "install 复制后内容正确（chmod 失败不影响文件内容）"

# install -m 设置权限 — 因 chmod 调用失败
mkfile "inst_mode.txt" "mode data"
bb_run install -m 755 "$TMPDIR/inst_mode.txt" "$TMPDIR/inst_mode_dst.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "install -m 755 因 chmod 在 WASI 下返回非零"

# install 复制到目录 — 因 chmod 失败
mkdir -p "$TMPDIR/inst_target_dir"
mkfile "inst_to_dir.txt" "to dir"
bb_run install "$TMPDIR/inst_to_dir.txt" "$TMPDIR/inst_target_dir/"
cmp_ok "$_BB_EXIT" "!=" "0" "install 复制到目录因 chmod 返回非零"

# install 源文件不存在应失败（正常行为）
bb_run install "$TMPDIR/nonexistent_inst.txt" "$TMPDIR/inst_bad.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "install 源文件不存在返回非零"

# install 多个文件到目录 — 因 chmod 失败
mkfile "inst_m1.txt" "m1"
mkfile "inst_m2.txt" "m2"
mkdir -p "$TMPDIR/inst_multi_dir"
bb_run install "$TMPDIR/inst_m1.txt" "$TMPDIR/inst_m2.txt" "$TMPDIR/inst_multi_dir/"
cmp_ok "$_BB_EXIT" "!=" "0" "install 多文件复制因 chmod 返回非零"

# install 无参数应报错
bb_run install
cmp_ok "$_BB_EXIT" "!=" "0" "install 无参数返回非零"

# install --help 正常工作（不依赖 chmod）
bb_run install --help
cmp_ok "$_BB_EXIT" "==" "0" "install --help 正常输出"

done_testing
