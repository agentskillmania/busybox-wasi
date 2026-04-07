#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# zcat 在 WASI 中不可用：
# - gzip 需要 dup2（ENOSYS），无法压缩文件
# - zcat 需要 pipe（ENOSYS），无法解压文件
# 所有 zcat 操作返回非零退出码

# gzip 在 WASI 中不可用（dup2 ENOSYS），因此无法创建 .gz 文件
mkfile "original.txt" "zcat test content"
bb_run gzip "$TMPDIR/original.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "gzip 在 WASI 中不可用（dup2 ENOSYS）"

# zcat 在 WASI 中不可用（pipe ENOSYS）
# 使用 host gzip 创建压缩文件来测试 zcat
host_gz_file="$TMPDIR/host_test.txt"
echo "host zcat test" > "$host_gz_file"
gzip -c "$host_gz_file" > "$TMPDIR/host_test.txt.gz"

bb_run zcat "$TMPDIR/host_test.txt.gz"
cmp_ok "$_BB_EXIT" "!=" "0" "zcat 在 WASI 中不可用（pipe ENOSYS）"

# zcat 不存在的文件返回非零
bb_run zcat "$TMPDIR/no_such.gz"
cmp_ok "$_BB_EXIT" "!=" "0" "zcat 不存在的文件返回非零"

# zcat 从 stdin 读取同样不可用
mkfile "stdin_test.txt" "stdin zcat data"
gzip -c "$TMPDIR/stdin_test.txt" > "$TMPDIR/stdin_test.txt.gz"
bb_run_stdin "$(cat "$TMPDIR/stdin_test.txt.gz")" zcat
cmp_ok "$_BB_EXIT" "!=" "0" "zcat 从 stdin 读取在 WASI 中不可用"

# zcat 无参数返回非零
bb_run zcat
cmp_ok "$_BB_EXIT" "!=" "0" "zcat 无参数返回非零"

# 验证 zcat 不是段错误
bb_run_capture zcat "$TMPDIR/host_test.txt.gz" 2>/dev/null || true
unlike "${_BB_STDERR:-}" "SIGSEGV|signal" "zcat 失败但不产生段错误"

# zcat 在 wsh 中同样不可用
bb_run_wsh "zcat $TMPDIR/host_test.txt.gz"
cmp_ok "$_BB_EXIT" "!=" "0" "zcat 在 wsh 中不可用"

done_testing
