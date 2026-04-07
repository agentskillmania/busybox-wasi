#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 12

# ========== 小写转大写 ==========
bb_run_stdin "hello world" tr 'a-z' 'A-Z'
is "$_BB_STDOUT" "HELLO WORLD" "tr 小写转大写"

# ========== 大写转小写 ==========
bb_run_stdin "HELLO" tr 'A-Z' 'a-z'
is "$_BB_STDOUT" "hello" "tr 大写转小写"

# ========== -d 删除字符 ==========
bb_run_stdin "hello world" tr -d 'lo'
is "$_BB_STDOUT" "he wrd" "tr -d 删除指定字符"

# ========== -s 压缩重复 ==========
bb_run_stdin "aaabbbccc" tr -s 'a-c'
is "$_BB_STDOUT" "abc" "tr -s 压缩重复字符"

# ========== -c 补集替换 ==========
bb_run_stdin "abc123" tr -c 'a-z' 'X'
is "$_BB_STDOUT" "abcXXX" "tr -c 补集替换数字为 X"

# ========== 替换单个字符 ==========
bb_run_stdin "aabbcc" tr 'ab' 'xy'
is "$_BB_STDOUT" "xxyycc" "tr 替换多个字符"

# ========== 数字替换 ==========
bb_run_stdin "12345" tr '1-5' 'abcde'
is "$_BB_STDOUT" "abcde" "tr 范围替换数字"

# ========== 空格替换为换行 ==========
bb_run_stdin "a b c" tr ' ' '\n'
is "$_BB_STDOUT" $'a\nb\nc' "tr 空格替换为换行"

# ========== 空输入 ==========
bb_run_stdin "" tr 'a' 'b'
is "$_BB_STDOUT" "" "tr 空输入无输出"

# ========== -d 删除数字 ==========
bb_run_stdin "abc123def456" tr -d '0-9'
is "$_BB_STDOUT" "abcdef" "tr -d 删除所有数字"

# ========== -s 压缩空格 ==========
bb_run_stdin "hello    world" tr -s ' '
is "$_BB_STDOUT" "hello world" "tr -s 压缩多余空格"

# ========== -cd 删除补集 ==========
bb_run_stdin "abc123xyz" tr -cd 'a-z'
is "$_BB_STDOUT" "abcxyz" "tr -cd 只保留字母"

done_testing
