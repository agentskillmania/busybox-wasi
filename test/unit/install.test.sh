#!/bin/bash
# install 在 WASI 下的行为：
# - 文件复制成功，但后续 chmod() 调用 ENOSYS 导致退出码非零
# - install -d 使用 mkdir -p，因路径遍历到 "/" 失败
# - 文件内容确实被正确复制，即使退出码非零
source "$(dirname "$0")/../helper.sh"
plan 8

# install 复制文件 — 文件被正确复制，但 chmod 报 ENOSYS 导致非零退出
mkfile "inst_src.txt" "install content"
bb_run install "$TMPDIR/inst_src.txt" "$TMPDIR/inst_dst.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "install 复制文件因 chmod 返回非零"

# 验证文件内容确实被正确复制（关键：实际功能验证）
bb_run cat "$TMPDIR/inst_dst.txt"
is "$_BB_STDOUT" "install content" "install 复制后文件内容正确"

# install 复制第二个文件验证
mkfile "inst_src2.txt" "another file"
bb_run install "$TMPDIR/inst_src2.txt" "$TMPDIR/inst_dst2.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "install 第二次复制也因 chmod 非零"
bb_run cat "$TMPDIR/inst_dst2.txt"
is "$_BB_STDOUT" "another file" "install 第二次复制内容正确"

# install -m 设置权限 — chmod 不可用，但文件仍被复制
mkfile "inst_mode.txt" "mode data"
bb_run install -m 755 "$TMPDIR/inst_mode.txt" "$TMPDIR/inst_mode_dst.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "install -m 因 chmod 返回非零"
bb_run cat "$TMPDIR/inst_mode_dst.txt"
is "$_BB_STDOUT" "mode data" "install -m 文件内容仍然正确复制"

# install 源文件不存在应失败
bb_run install "$TMPDIR/nonexistent.txt" "$TMPDIR/bad.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "install 源文件不存在返回非零"

# install --help 不依赖 chmod
bb_run install --help
cmp_ok "$_BB_EXIT" "==" "0" "install --help 正常输出"

done_testing
