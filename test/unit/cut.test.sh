#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 13

# ========== 准备测试数据 ==========
f=$(mkfile "data.txt" $'root:x:0:0\nnobody:x:65534:65534\ndaemon:x:1:1')

# ========== cut -d 指定分隔符 -f 指定字段 ==========
bb_run cut -d: -f1 "$f"
like "$_BB_STDOUT" "root" "cut -d: -f1 提取第一字段"
unlike "$_BB_STDOUT" ":" "cut 提取结果不含分隔符"

# ========== 多个字段 ==========
bb_run cut -d: -f1,3 "$f"
like "$_BB_STDOUT" "root:0" "cut -f1,3 提取多个字段"

# ========== 范围字段 ==========
bb_run cut -d: -f1-2 "$f"
like "$_BB_STDOUT" "root:x" "cut -f1-2 提取字段范围"

# ========== -c 字符位置 ==========
bb_run_stdin "hello world" cut -c1-5
is "$_BB_STDOUT" "hello" "cut -c1-5 提取前 5 个字符"

# ========== -c 单个字符 ==========
bb_run_stdin "abcdef" cut -c3
is "$_BB_STDOUT" "c" "cut -c3 提取第三个字符"

# ========== -b 字节位置 ==========
bb_run_stdin "ABCDEF" cut -b2-4
is "$_BB_STDOUT" "BCD" "cut -b2-4 提取字节范围"

# ========== 从文件读取 ==========
f2=$(mkfile "words.txt" "one two three")
bb_run cut -d" " -f2 "$f2"
is "$_BB_STDOUT" "two" "cut 从文件读取提取第二字段"

# ========== 空输入 ==========
bb_run_stdin "" cut -d: -f1
is "$_BB_STDOUT" "" "cut 空输入无输出"

# ========== 多行处理 ==========
bb_run_stdin $'a:b:c\nd:e:f' cut -d: -f2
is "$_BB_STDOUT" $'b\ne' "cut 多行处理"

# ========== -c 不连续位置 ==========
bb_run_stdin "abcdef" cut -c1,3,5
is "$_BB_STDOUT" "ace" "cut -c1,3,5 提取不连续字符"

# ========== -f 末尾字段 ==========
f3=$(mkfile "csv.txt" $'a,b,c,d\ne,f,g,h')
bb_run cut -d, -f4 "$f3"
is "$_BB_STDOUT" $'d\nh' "cut -f4 提取最后一个字段"

# ========== 字段超出范围 ==========
bb_run_stdin "a:b" cut -d: -f5
is "$_BB_STDOUT" "" "cut 字段超出范围返回空"

done_testing
