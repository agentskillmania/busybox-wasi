#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# 基本行数统计
bb_run_stdin $'one\ntwo\nthree' wc -l
is "$_BB_STDOUT" "3" "wc -l 统计行数"

# 单行
bb_run_stdin "hello" wc -l
is "$_BB_STDOUT" "1" "wc -l 单行"

# 空输入
bb_run_stdin "" wc -l
is "$_BB_STDOUT" "0" "wc -l 空输入"

# 单词统计
bb_run_stdin "hello world foo" wc -w
is "$_BB_STDOUT" "3" "wc -w 统计单词"

# 字节统计
bb_run_stdin "hello" wc -c
is "$_BB_STDOUT" "5" "wc -c 统计字节数"

# 文件输入
f=$(mkfile "data.txt" $'a\nb\nc\nd')
bb_run wc -l "$f"
like "$_BB_STDOUT" "4" "wc -l 从文件统计"

# 字符统计
bb_run_stdin "hello" wc -m
is "$_BB_STDOUT" "5" "wc -m 统计字符数"

# 最长行
bb_run_stdin $'hi\nhello\nx' wc -L
like "$_BB_STDOUT" "5" "wc -L 最长行长度"

done_testing
