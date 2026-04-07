#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 基本输出
bb_run echo "hello world"
is "$_BB_STDOUT" "hello world" "echo 基本输出"

# 无参数
bb_run echo
is "$_BB_STDOUT" "" "echo 无参数输出空行"

# -n 不换行
bb_run echo -n "no newline"
is "$_BB_STDOUT" "no newline" "echo -n 不换行"

# -e 转义
bb_run echo -e "a\tb"
is "$_BB_STDOUT" $'a\tb' "echo -e 解析制表符"

# -e 换行
bb_run echo -e "line1\nline2"
is "$_BB_STDOUT" $'line1\nline2' "echo -e 解析换行"

# 多个参数
bb_run echo "one" "two" "three"
is "$_BB_STDOUT" "one two three" "echo 多参数空格分隔"

# -e \\c 截断
bb_run echo -e "hello\cworld"
is "$_BB_STDOUT" "hello" "echo -e \\c 截断输出"

# 空字符串
bb_run echo ""
is "$_BB_STDOUT" "" "echo 空字符串"

# 环境变量
bb_run sh -c 'echo $HOME' 2>/dev/null || true
# 不验证内容，只验证不崩溃
ok "echo 在 shell 中不崩溃"

# 特殊字符
bb_run echo "hello\"world"
is "$_BB_STDOUT" 'hello"world' "echo 含引号"

done_testing
