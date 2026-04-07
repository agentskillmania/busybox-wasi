#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 基本整数输出
bb_run printf '%d' 42
is "$_BB_STDOUT" "42" "printf %%d 输出整数"

# 带换行的字符串
bb_run printf '%s\n' hello
# bash $() 剥离尾部换行，实际得到 "hello"
is "$_BB_STDOUT" "hello" "printf %%s\\n 带换行"

# 零填充
bb_run printf '%05d' 3
is "$_BB_STDOUT" "00003" "printf %%05d 零填充"

# 浮点数
bb_run printf '%.2f' 3.14159
is "$_BB_STDOUT" "3.14" "printf %%.2f 两位小数"

# 八进制
bb_run printf '%o' 255
is "$_BB_STDOUT" "377" "printf %%o 八进制"

# 十六进制
bb_run printf '%x' 255
is "$_BB_STDOUT" "ff" "printf %%x 十六进制小写"

# 大写十六进制
bb_run printf '%X' 255
is "$_BB_STDOUT" "FF" "printf %%X 十六进制大写"

# 多个参数
bb_run printf '%s %s' hello world
is "$_BB_STDOUT" "hello world" "printf 多参数"

# 转义序列 \t
bb_run printf 'a\tb'
is "$_BB_STDOUT" $'a\tb' "printf \\t 制表符转义"

# 转义序列 \\ 输出反斜杠
bb_run printf '\\'
is "$_BB_STDOUT" "\\" "printf \\\\ 输出反斜杠"

done_testing
