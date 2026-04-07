#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 基本折行 ==========
bb_run_stdin "abcdefghijklmn" fold -w 5
is "$_BB_STDOUT" $'abcde\nfghij\nklmn' "fold -w 5 每行最多 5 字符"

# ========== 宽度等于行长度 ==========
bb_run_stdin "hello" fold -w 5
is "$_BB_STDOUT" "hello" "fold 宽度等于行长度不变"

# ========== 宽度超过行长度 ==========
bb_run_stdin "hi" fold -w 10
is "$_BB_STDOUT" "hi" "fold 宽度超过行长度不变"

# ========== -s 在空格处断行 ==========
bb_run_stdin "hello world foo bar" fold -w 10 -s
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
is "$count" "3" "fold -s 在空格处断行"

# ========== 从文件读取 ==========
f=$(mkfile "data.txt" "abcdefghij")
bb_run fold -w 5 "$f"
is "$_BB_STDOUT" $'abcde\nfghij' "fold 从文件读取"

# ========== 多行输入 ==========
bb_run_stdin $'1234567890\nabcdef' fold -w 5
is "$_BB_STDOUT" $'12345\n67890\nabcde\nf' "fold 多行输入"

# ========== 空输入 ==========
bb_run_stdin "" fold -w 10
is "$_BB_STDOUT" "" "fold 空输入无输出"

# ========== 默认宽度 80 ==========
long_line=""
for i in $(seq 1 100); do long_line="${long_line}x"; done
bb_run_stdin "$long_line" fold
count=$(echo "$_BB_STDOUT" | wc -l | tr -d ' ')
cmp_ok "$count" ">" "1" "fold 默认宽度 80 超长行被折行"

# ========== -w 1 每字符一行 ==========
bb_run_stdin "abc" fold -w 1
is "$_BB_STDOUT" $'a\nb\nc' "fold -w 1 每字符一行"

# ========== -w 3 奇数宽度 ==========
bb_run_stdin "abcdefg" fold -w 3
is "$_BB_STDOUT" $'abc\ndef\ng' "fold -w 3 奇数宽度折行"

done_testing
