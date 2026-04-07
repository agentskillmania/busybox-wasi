#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 准备测试数据 ==========
f1=$(mkfile "a.txt" $'a\nb\nc')
f2=$(mkfile "b.txt" $'1\n2\n3')

# ========== 基本合并 ==========
bb_run paste "$f1" "$f2"
is "$_BB_STDOUT" $'a\t1\nb\t2\nc\t3' "paste 基本合并两文件"

# ========== -d 自定义分隔符 ==========
bb_run paste -d: "$f1" "$f2"
is "$_BB_STDOUT" $'a:1\nb:2\nc:3' "paste -d: 使用冒号分隔"

# ========== -s 串行合并 ==========
bb_run paste -s "$f1"
is "$_BB_STDOUT" $'a\tb\tc' "paste -s 串行合并为单行"

# ========== -s 自定义分隔符 ==========
bb_run paste -s -d: "$f2"
is "$_BB_STDOUT" "1:2:3" "paste -s -d: 串行合并用冒号分隔"

# ========== 三个文件合并 ==========
f3=$(mkfile "c.txt" $'x\ny\nz')
bb_run paste "$f1" "$f2" "$f3"
like "$_BB_STDOUT" "a.*1.*x" "paste 合并三个文件"

# ========== 单个文件 ==========
bb_run paste "$f1"
is "$_BB_STDOUT" $'a\nb\nc' "paste 单文件输出不变"

# ========== 不同行数文件 ==========
f4=$(mkfile "short.txt" $'a\nb')
f5=$(mkfile "long.txt" $'1\n2\n3')
bb_run paste "$f4" "$f5"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "3" "paste 不同行数文件按最长行对齐"

# ========== 空文件合并 ==========
f6=$(mkfile "empty.txt" "")
bb_run paste "$f6" "$f1"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "3" "paste 空文件与有内容文件合并"

# ========== -d 多字符分隔符 ==========
bb_run paste -d',|' "$f1" "$f2" "$f3"
like "$_BB_STDOUT" "a,1" "paste -d 多分隔符"

# ========== -s 多文件 ==========
bb_run paste -s "$f1" "$f2"
like "$_BB_STDOUT" "a" "paste -s 多文件串行合并"

done_testing
