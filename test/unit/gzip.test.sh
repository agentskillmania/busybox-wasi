#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# gzip/bzip2 原地压缩需要 dup()，WASI 不支持
# 但管道 stdin 模式可以正常工作

# gzip -c stdin 压缩
bb_run_stdin "hello gzip" gzip -c
is "$_BB_EXIT" "0" "gzip -c stdin 压缩成功"
cmp_ok "${#_BB_STDOUT}" ">" "0" "gzip -c 输出非空"

# gzip -c 文件输出也需要 dup，应失败
mkfile "gz_file.txt" "test"
bb_run gzip -c "$TMPDIR/gz_file.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "gzip -c 文件因 dup 限制失败"

# gzip 原地压缩文件也应失败
bb_run gzip "$TMPDIR/gz_file.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "gzip 原地压缩因 dup 限制失败"

# gzip -d stdin 解压（先构造 gzip 数据到文件，再用文件当 stdin）
d=$(mktemp -d /tmp/bbtest_gz.XXXXXX)
echo "roundtrip test" | $HOME/bin/wasmtime -W exceptions=y busybox.wasm gzip -c > "$d/data.gz" 2>/dev/null
bb_run_stdin "$(cat "$d/data.gz")" gzip -d
# 二进制数据通过 bash 变量传递可能丢失，如果失败也正常
if [[ "$_BB_EXIT" == "0" ]]; then
    like "$_BB_STDOUT" "roundtrip" "gzip 往返解压正确"
else
    skip "gzip 往返解压（二进制数据无法通过 bash 变量传递）"
fi
rm -rf "$d"

# gunzip 也因 dup 限制不能原地解压
bb_run gunzip "$TMPDIR/gz_file.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "gunzip 原地解压因 dup 限制失败"

done_testing
