#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# getopt 基本解析：选项 ab:c，参数 -a -b hello arg
bb_run getopt ab:c -a -b hello arg
is "$_BB_EXIT" "0" "getopt 解析选项不崩溃"

# 输出包含解析结果
bb_run getopt ab:c -a -b hello arg
like "$_BB_STDOUT" "\-a" "getopt 输出包含 -a 选项"

# 输出包含 -b 的参数
bb_run getopt ab:c -a -b hello arg
like "$_BB_STDOUT" "hello" "getopt 输出包含 -b 的参数 hello"

# 输出包含非选项参数
bb_run getopt ab:c -a -b hello arg
like "$_BB_STDOUT" "arg" "getopt 输出包含非选项参数 arg"

# -n 指定程序名
bb_run getopt -n myprog ab:c -a -b hello
is "$_BB_EXIT" "0" "getopt -n 指定程序名不崩溃"

# 无效选项应报错
bb_run getopt ab:c -x
cmp_ok "$_BB_EXIT" "!=" "0" "getopt 无效选项返回非零"

# 通过 wsh 调用
bb_run_wsh 'getopt ab:c -a -b hello arg'
is "$_BB_EXIT" "0" "getopt 在 wsh 中正常"

done_testing
