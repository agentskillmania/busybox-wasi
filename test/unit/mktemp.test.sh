#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# mktemp 在 WASI 中：基本 mktemp（文件）不可用（mkstemp ENOSYS）
# mktemp -d（目录）可以工作（不调用 mkstemp）

# mktemp 创建文件不可用（mkstemp ENOSYS）
bb_run mktemp
cmp_ok "$_BB_EXIT" "!=" "0" "mktemp 创建文件在 WASI 中不可用（mkstemp ENOSYS）"

# mktemp -d 创建目录可以工作
bb_run mktemp -d
is "$_BB_EXIT" "0" "mktemp -d 创建临时目录成功"
like "$_BB_STDOUT" "tmp" "mktemp -d 输出包含路径"

# mktemp 指定模板（文件）不可用
bb_run mktemp "$TMPDIR/mktest.XXXXXX"
cmp_ok "$_BB_EXIT" "!=" "0" "mktemp 指定模板创建文件不可用"

# mktemp -p 指定目录（文件）不可用
bb_run mktemp -p "$TMPDIR"
cmp_ok "$_BB_EXIT" "!=" "0" "mktemp -p 指定目录创建文件不可用"

# mktemp -q 安静模式（文件）不可用
bb_run mktemp -q
cmp_ok "$_BB_EXIT" "!=" "0" "mktemp -q 安静模式不可用"

# mktemp -t（文件）不可用
bb_run mktemp -t myprefix.XXXXXX
cmp_ok "$_BB_EXIT" "!=" "0" "mktemp -t 创建文件不可用"

# mktemp -d -p 指定目录创建目录
bb_run mktemp -d -p "$TMPDIR"
is "$_BB_EXIT" "0" "mktemp -d -p 创建临时目录成功"

# mktemp 无参数（文件）不可用，但不崩溃
bb_run_capture mktemp
unlike "$_BB_STDERR" "SIGSEGV|signal" "mktemp 失败但不产生段错误"

done_testing
