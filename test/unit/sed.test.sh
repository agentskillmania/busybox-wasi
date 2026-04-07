#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 12

# ========== 基本替换 ==========
bb_run_stdin "hello world" sed "s/hello/goodbye/"
is "$_BB_STDOUT" "goodbye world" "sed 基本替换"

# ========== 全局替换 ==========
bb_run_stdin "aaa bbb aaa" sed "s/aaa/xxx/g"
is "$_BB_STDOUT" "xxx bbb xxx" "sed 全局替换 g 标志"

# ========== -n 抑制默认输出 ==========
bb_run_stdin $'line1\nline2\nline3' sed -n "2p"
is "$_BB_STDOUT" "line2" "sed -n '2p' 只打印第二行"

# ========== -e 多个表达式 ==========
bb_run_stdin "hello world" sed -e "s/hello/foo/" -e "s/world/bar/"
is "$_BB_STDOUT" "foo bar" "sed -e 多个表达式"

# ========== 删除行 ==========
bb_run_stdin $'keep\ndelete\nkeep2' sed "/delete/d"
is "$_BB_STDOUT" $'keep\nkeep2' "sed /pattern/d 删除匹配行"

# ========== 从文件读取 ==========
f=$(mkfile "data.txt" "old text here")
bb_run sed "s/old/new/" "$f"
like "$_BB_STDOUT" "new text here" "sed 从文件读取并替换"

# ========== 打印行号 ==========
bb_run_stdin $'aaa\nbbb\nccc' sed -n "2p"
is "$_BB_STDOUT" "bbb" "sed 打印指定行"

# ========== 替换首行 ==========
bb_run_stdin $'first\nsecond\nthird' sed "1s/first/1st/"
like "$_BB_STDOUT" "1st" "sed 替换首行"

# ========== 空输入 ==========
bb_run_stdin "" sed "s/a/b/"
is "$_BB_STDOUT" "" "sed 空输入无输出"

# ========== 多行替换 ==========
bb_run_stdin $'a\nb\nc' sed "s/b/B/"
like "$_BB_STDOUT" "B" "sed 多行替换中间行"

# ========== -n 和范围 ==========
bb_run_stdin $'1\n2\n3\n4\n5' sed -n "2,4p"
is "$_BB_STDOUT" $'2\n3\n4' "sed -n 范围打印"

# ========== 末尾追加 ==========
bb_run_stdin "line" sed "s/$/ END/"
is "$_BB_STDOUT" "line END" "sed 行尾追加文本"

done_testing
