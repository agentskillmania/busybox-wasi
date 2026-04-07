#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 11

# ========== 准备测试数据 ==========
f=$(mkfile "data.txt" $'apple\nbanana\ncherry\ndate\nelderberry')

# ========== 扩展正则 — 或操作 ==========
bb_run egrep "apple|cherry" "$f"
like "$_BB_STDOUT" "apple" "egrep 或操作匹配 apple"
like "$_BB_STDOUT" "cherry" "egrep 或操作匹配 cherry"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "2" "egrep 或操作匹配两行"

# ========== 扩展正则 — 加号 ==========
bb_run egrep "a+" "$f"
like "$_BB_STDOUT" "apple" "egrep 加号匹配 apple"
like "$_BB_STDOUT" "banana" "egrep 加号匹配 banana"

# ========== 扩展正则 — 问号 ==========
bb_run egrep "colou?r" "$f"
is "$_BB_EXIT" "1" "egrep 问号不匹配时退出码 1"

# ========== 扩展正则 — 分组 ==========
f2=$(mkfile "group.txt" $'abcabc\nxyz\nabc')
bb_run egrep "(abc)+" "$f2"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "2" "egrep 分组匹配两行"

# ========== 不匹配退出码 ==========
bb_run egrep "ZZZ" "$f"
is "$_BB_EXIT" "1" "egrep 不匹配退出码 1"

# ========== -i 忽略大小写 ==========
f3=$(mkfile "case.txt" $'Hello\nworld\nHELLO')
bb_run egrep -i "hello" "$f3"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "2" "egrep -i 忽略大小写匹配两行"

# ========== 从 stdin 读取 ==========
bb_run_stdin $'cat\ndog\nbird' egrep "cat|dog"
like "$_BB_STDOUT" "cat" "egrep 从 stdin 读取匹配 cat"
like "$_BB_STDOUT" "dog" "egrep 从 stdin 读取匹配 dog"

done_testing
