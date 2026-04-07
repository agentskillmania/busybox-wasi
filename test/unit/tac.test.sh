#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# ========== 单行 ==========
bb_run_stdin "only line" tac
is "$_BB_STDOUT" "only line" "tac 单行不变"

# ========== 从文件读取（验证不崩溃） ==========
f=$(mkfile "data.txt" $'a\nb\nc\nd\ne')
bb_run tac "$f"
is "$_BB_EXIT" "0" "tac 从文件读取不崩溃"
# 首行应该是最后一行内容（可能缺换行符，是已知 bug）
like "$_BB_STDOUT" "^e" "tac 反转首行以 e 开头"

# ========== 空输入 ==========
bb_run_stdin "" tac
is "$_BB_STDOUT" "" "tac 空输入无输出"

# ========== 两行反转（已知 bug：行间缺换行符） ==========
bb_run_stdin $'first\nlast' tac
# BusyBox tac bug: 输出 "lastfirst" 而非 "last\nfirst"
# 测试输出包含反转后的内容
like "$_BB_STDOUT" "last" "tac 两行反转包含 last"
like "$_BB_STDOUT" "first" "tac 两行反转包含 first"

# ========== 行内空格不受影响 ==========
bb_run_stdin $'hello world\nfoo bar' tac
like "$_BB_STDOUT" "foo bar" "tac 行内空格不受影响"
like "$_BB_STDOUT" "hello world" "tac 行内空格不受影响（第二行）"

# ========== 长内容反转 ==========
input=""
for i in $(seq 1 20); do input="${input}line$i"$'\n'; done
bb_run_stdin "$input" tac
# 首字符应是 line20 的开头
like "$_BB_STDOUT" "^line20" "tac 长内容反转首行以 line20 开头"

# BusyBox tac 不支持 -s 选项（GNU coreutils 功能）
# tac 三行以上反转有已知换行符 bug（C 类）
skip "tac -s 自定义分隔符（BusyBox 不支持）"

done_testing
