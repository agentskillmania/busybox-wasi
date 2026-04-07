#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 准备测试数据 ==========
f=$(mkfile "data.txt" $'hello world\nfoo.bar\nhello.bar\nbaz')

# ========== 固定字符串搜索 ==========
bb_run fgrep "hello" "$f"
like "$_BB_STDOUT" "hello world" "fgrep 固定字符串匹配"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "1" "fgrep 匹配一行"

# ========== 固定字符串不解释正则元字符 ==========
bb_run fgrep "foo.bar" "$f"
like "$_BB_STDOUT" "foo.bar" "fgrep 不解释正则元字符匹配 foo.bar"
unlike "$_BB_STDOUT" "hello.bar" "fgrep 不匹配 hello.bar（.不是通配符）"

# ========== 不匹配退出码 ==========
bb_run fgrep "nonexistent" "$f"
is "$_BB_EXIT" "1" "fgrep 不匹配退出码 1"

# ========== 匹配退出码 ==========
bb_run fgrep "hello" "$f"
is "$_BB_EXIT" "0" "fgrep 匹配退出码 0"

# ========== 错误退出码（文件不存在）==========
bb_run fgrep "x" "$TMPDIR/no_such_file.txt"
is "$_BB_EXIT" "2" "fgrep 文件不存在退出码 2"

# ========== -c 计数 ==========
bb_run fgrep -c "hello" "$f"
is "$_BB_STDOUT" "1" "fgrep -c 统计匹配行数"

# ========== -v 反转 ==========
bb_run fgrep -v "hello" "$f"
unlike "$_BB_STDOUT" "hello" "fgrep -v 反转不包含 hello"

# ========== 从 stdin 读取 ==========
bb_run_stdin $'aaa\nbbb\naaa' fgrep "aaa"
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "2" "fgrep 从 stdin 读取匹配两行"

done_testing
