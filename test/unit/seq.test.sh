#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

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

# 倒序（需显式负步长）
bb_run seq 5 -1 1
is "$_BB_STDOUT" $'5\n4\n3\n2\n1' "seq 显式负步长倒序"

# -s 分隔符
bb_run seq -s, 3
is "$_BB_STDOUT" "1,2,3" "seq -s 自定义分隔符"

# -w 等宽
bb_run seq -w 8 10
like "$_BB_STDOUT" "08" "seq -w 等宽补零"

# 负数
bb_run seq -3 0
is "$_BB_STDOUT" $'-3\n-2\n-1\n0' "seq 负数"

# BusyBox seq 不支持 -f 格式化、自动倒序、步长 0 会死循环
# 步长 0 导致死循环，用 skip 标注
skip "seq 步长为 0 会死循环（BusyBox 未校验）"

done_testing
