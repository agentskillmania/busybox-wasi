#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 12

# ========== 打印第一列 ==========
bb_run_stdin "hello world" awk '{print $1}'
is "$_BB_STDOUT" "hello" "awk 打印第一列"

# ========== -F 自定义字段分隔符 ==========
bb_run_stdin "a:b:c" awk -F: '{print $2}'
is "$_BB_STDOUT" "b" "awk -F: 按冒号分隔打印第二列"

# ========== BEGIN 块 ==========
bb_run_stdin "data" awk 'BEGIN{print "start"} {print}'
is "$_BB_STDOUT" $'start\ndata' "awk BEGIN 块在处理前执行"

# ========== END 块 ==========
bb_run_stdin $'1\n2\n3' awk '{s+=$1} END{print s}'
is "$_BB_STDOUT" "6" "awk END 块计算总和"

# ========== 变量赋值 ==========
bb_run_stdin "hello" awk -v x=42 '{print x}'
is "$_BB_STDOUT" "42" "awk -v 变量赋值"

# ========== 算术运算 ==========
bb_run_stdin "10 3" awk '{print $1 + $2}'
is "$_BB_STDOUT" "13" "awk 算术加法"

# ========== length 函数 ==========
bb_run_stdin "hello" awk '{print length}'
is "$_BB_STDOUT" "5" "awk length 函数返回字符串长度"

# ========== printf 格式化 ==========
bb_run_stdin "world" awk '{printf "hello %s\n", $1}'
is "$_BB_STDOUT" "hello world" "awk printf 格式化输出"

# ========== NR 行号 ==========
bb_run_stdin $'a\nb\nc' awk '{print NR, $0}'
like "$_BB_STDOUT" "1 a" "awk NR 输出行号"

# ========== NF 字段数 ==========
bb_run_stdin "one two three" awk '{print NF}'
is "$_BB_STDOUT" "3" "awk NF 输出字段数"

# ========== 从文件读取 ==========
f=$(mkfile "data.txt" "foo bar")
bb_run awk '{print $2}' "$f"
is "$_BB_STDOUT" "bar" "awk 从文件读取"

# ========== 条件匹配 ==========
bb_run_stdin $'1\n2\n3\n4\n5' awk '$1 > 3 {print}'
is "$_BB_STDOUT" $'4\n5' "awk 条件过滤大于 3 的行"

done_testing
