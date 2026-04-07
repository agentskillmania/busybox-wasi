#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 基本拓扑排序: a->b, b->c => a b c
file=$(mkfile "tsort1.txt" "a b
b c")
bb_run tsort "$file"
is "$_BB_STDOUT" $'a\nb\nc' "tsort 基本拓扑排序 a->b->c"

# 线性依赖: x->y
file2=$(mkfile "tsort2.txt" "x y")
bb_run tsort "$file2"
is "$_BB_STDOUT" $'x\ny' "tsort 两个节点线性排序"

# 互不依赖: a b 和 c d
file3=$(mkfile "tsort3.txt" "a b
c d")
bb_run tsort "$file3"
is "$_BB_EXIT" "0" "tsort 互不依赖的组不崩溃"

# 单对输入
file4=$(mkfile "tsort4.txt" "1 2")
bb_run tsort "$file4"
is "$_BB_STDOUT" $'1\n2' "tsort 单对输入"

# 菱形依赖: a->b, a->c, b->d, c->d
file5=$(mkfile "tsort5.txt" "a b
a c
b d
c d")
bb_run tsort "$file5"
# a 必须在 b 和 c 之前，b 和 c 必须在 d 之前
like "$_BB_STDOUT" "^a" "tsort 菱形依赖 a 排在最前"
like "$_BB_STDOUT" "d$" "tsort 菱形依赖 d 排在最后"

done_testing
