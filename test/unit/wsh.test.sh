#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 20

# === 变量赋值和展开 ===
bb_run_wsh 'X=hello; echo $X'
is "$_BB_STDOUT" "hello" "wsh 变量赋值和展开"

bb_run_wsh 'NAME=test; echo ${NAME}'
is "$_BB_STDOUT" "test" "wsh 变量花括号展开"

# === 命令替换 ===
bb_run_wsh 'echo $(echo inner)'
is "$_BB_STDOUT" "inner" "wsh 命令替换"

bb_run_wsh 'echo $(echo $(echo deep))'
is "$_BB_STDOUT" "deep" "wsh 嵌套命令替换"

# === 管道 ===
bb_run_wsh 'echo hello | tr a-z A-Z'
is "$_BB_STDOUT" "HELLO" "wsh 单管道"

bb_run_wsh 'echo -e "banana\napple\ncherry" | sort | head -1'
is "$_BB_STDOUT" "apple" "wsh 多级管道"

# === 分号分隔 ===
bb_run_wsh 'echo one; echo two'
is "$_BB_STDOUT" $'one\ntwo' "wsh 分号分隔多条命令"

# === 控制流 ===
bb_run_wsh 'if true; then echo yes; fi'
is "$_BB_STDOUT" "yes" "wsh if true"

bb_run_wsh 'if false; then echo yes; else echo no; fi'
is "$_BB_STDOUT" "no" "wsh if/else"

bb_run_wsh 'for i in a b c; do echo $i; done'
is "$_BB_STDOUT" $'a\nb\nc' "wsh for 循环"

bb_run_wsh 'X=0; while test $X -lt 3; do echo $X; X=$(expr $X + 1); done'
is "$_BB_STDOUT" $'0\n1\n2' "wsh while 循环"

# === 特殊变量 ===
bb_run_wsh 'true; echo $?'
is "$_BB_STDOUT" "0" "wsh $? 捕获退出码 0"

bb_run_wsh 'false; echo $?'
is "$_BB_STDOUT" "1" "wsh $? 捕获退出码 1"

bb_run_wsh 'echo $$'
is "$_BB_STDOUT" "1" "wsh $$ 返回伪 PID 1"

# === 引号 ===
bb_run_wsh "echo 'hello world'"
is "$_BB_STDOUT" "hello world" "wsh 单引号保留空格"

# === 错误处理 ===
bb_run_wsh 'nonexistent_cmd_xyz'
cmp_ok "$_BB_EXIT" "!=" "0" "wsh 不存在的命令返回非零"

# === 变量在命令替换中赋值 ===
bb_run_wsh 'F=dummy; F=$(echo replaced); echo $F'
is "$_BB_STDOUT" "replaced" "wsh 命令替换赋值"

# === 调用各命令 ===
bb_run_wsh 'echo hello | wc -c'
like "$_BB_STDOUT" "6" "wsh 通过管道调用 wc"

bb_run_wsh 'seq 1 5 | sort -r | head -1'
like "$_BB_STDOUT" "5" "wsh 管道调用 sort"

done_testing
