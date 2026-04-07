#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 基本序列
bb_run seq 5
is "$_BB_STDOUT" $'1\n2\n3\n4\n5' "seq 1-5"

# 起止
bb_run seq 3 7
is "$_BB_STDOUT" $'3\n4\n5\n6\n7' "seq 3-7"

# 步长
bb_run seq 2 2 10
is "$_BB_STDOUT" $'2\n4\n6\n8\n10' "seq 步长 2"

# 单值
bb_run seq 1
is "$_BB_STDOUT" "1" "seq 1"

# 倒序
bb_run seq 5 1
is "$_BB_STDOUT" $'5\n4\n3\n2\n1' "seq 倒序"

# -s 分隔符
bb_run seq -s, 3
is "$_BB_STDOUT" "1,2,3" "seq -s 自定义分隔符"

# -w 等宽
bb_run seq -w 8 10
like "$_BB_STDOUT" "08" "seq -w 等宽补零"

# -f 格式
bb_run seq -f '%02g' 3
is "$_BB_STDOUT" $'01\n02\n03' "seq -f 格式化"

# 负数
bb_run seq -3 0
is "$_BB_STDOUT" $'-3\n-2\n-1\n0' "seq 负数"

# 0 步长报错
bb_run seq 0 0 5
cmp_ok "$_BB_EXIT" "!=" "0" "seq 步长为 0 报错"

done_testing
