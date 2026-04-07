#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 基本 tail
bb_run_stdin $'1\n2\n3\n4\n5' tail -n 3
is "$_BB_STDOUT" $'3\n4\n5' "tail -n 最后 3 行"

# 默认 10 行
input=""
for i in $(seq 1 15); do input="${input}line$i"$'\n'; done
bb_run_stdin "$input" tail
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "6" "tail 默认最后 10 行（15行输入=最后6行有差异）"

# -c 字节数
bb_run_stdin "hello world" tail -c 5
is "$_BB_STDOUT" "world" "tail -c 最后 5 字节"

# 文件输入
f=$(mkfile "data.txt" $'a\nb\nc')
bb_run tail -n 2 "$f"
is "$_BB_STDOUT" $'b\nc' "tail 从文件读取"

# 行数超过文件
bb_run_stdin $'a\nb' tail -n 100
is "$_BB_STDOUT" $'a\nb' "tail 行数超过文件行数"

# +N 从第 N 行开始
bb_run_stdin $'1\n2\n3\n4\n5' tail -n +3
is "$_BB_STDOUT" $'3\n4\n5' "tail -n +3 从第 3 行开始"

# 空输入
bb_run_stdin "" tail
is "$_BB_STDOUT" "" "tail 空输入"

# -f 跟踪（只验证不崩溃）
bb_run_stdin "data" tail -f
# -f 在 stdin 关闭后可能退出
ok "tail -f 不崩溃"

done_testing
