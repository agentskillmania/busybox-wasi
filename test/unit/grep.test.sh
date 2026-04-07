#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 14

# ========== 准备测试数据 ==========
f=$(mkfile "data.txt" $'apple\nbanana\ncherry\nApple Pie\ngrape')

# ========== 基本模式搜索 ==========
bb_run grep "apple" "$f"
is "$_BB_STDOUT" "apple" "grep 基本模式搜索"
is "$_BB_EXIT" "0" "grep 匹配时退出码为 0"

# ========== 不匹配退出码 ==========
bb_run grep "xyz" "$f"
is "$_BB_EXIT" "1" "grep 不匹配时退出码为 1"

# ========== 错误退出码（文件不存在）==========
bb_run grep "pattern" "$TMPDIR/nonexistent.txt"
is "$_BB_EXIT" "2" "grep 文件不存在时退出码为 2"

# ========== -c 计数 ==========
bb_run grep -c "apple" "$f"
is "$_BB_STDOUT" "1" "grep -c 统计匹配行数"

# ========== -v 反转匹配 ==========
bb_run grep -v "apple" "$f"
like "$_BB_STDOUT" "banana" "grep -v 反转匹配包含 banana"
unlike "$_BB_STDOUT" "^apple$" "grep -v 反转匹配不包含 apple"

# ========== -i 忽略大小写 ==========
bb_run grep -i "apple" "$f"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "2" "grep -i 忽略大小写匹配两行"

# ========== -n 显示行号 ==========
bb_run grep -n "banana" "$f"
like "$_BB_STDOUT" "^2:banana" "grep -n 显示行号"

# ========== -l 只显示文件名 ==========
bb_run grep -l "apple" "$f"
like "$_BB_STDOUT" "data.txt" "grep -l 只显示匹配的文件名"

# ========== 正则表达式 ==========
bb_run grep "^[a-c]" "$f"
like "$_BB_STDOUT" "apple" "grep 正则匹配 apple"
like "$_BB_STDOUT" "banana" "grep 正则匹配 banana"
like "$_BB_STDOUT" "cherry" "grep 正则匹配 cherry"

# ========== 从 stdin 读取 ==========
bb_run_stdin $'hello world\nfoo bar\nhello again' grep "hello"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "2" "grep 从 stdin 读取匹配两行"

done_testing
