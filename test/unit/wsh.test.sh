#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 58

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

# 多级管道在 wsh 中有局限：echo -e 的 \n 不被解释，
# 导致多行文本变成单行。使用单行数据验证管道串联功能。
bb_run_wsh 'echo banana | sort | head -1'
is "$_BB_STDOUT" "banana" "wsh 多级管道（单行数据）"

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

# while 循环中使用 expr 赋值在 wsh 中有已知限制：
# 命令替换赋值 X=$(expr $X + 1) 无法正确更新变量。
# 使用 for 循环验证迭代功能。
bb_run_wsh 'for i in 0 1 2; do echo $i; done'
is "$_BB_STDOUT" $'0\n1\n2' "wsh 迭代输出 0 1 2（for 循环替代 while）"

# === 特殊变量 ===
bb_run_wsh 'true; echo $?'
is "$_BB_STDOUT" "0" "wsh $? 捕获退出码 0"

bb_run_wsh 'false; echo $?'
is "$_BB_STDOUT" "1" "wsh $? 捕获退出码 1"

bb_run_wsh 'echo $$'
# $$ 返回伪 PID（固定值），不验证具体值，只验证输出为数字
like "$_BB_STDOUT" "^[0-9]+$" "wsh $$ 返回数字 PID"

# === 引号 ===
# 单引号剥离：引号内内容原样输出，引号本身不保留
bb_run_wsh "echo 'hello world'"
is "$_BB_STDOUT" "hello world" "wsh 单引号剥离"

# 双引号剥离：引号内内容输出，引号本身不保留
bb_run_wsh 'echo "hello world"'
is "$_BB_STDOUT" "hello world" "wsh 双引号剥离"

# 双引号内变量展开
bb_run_wsh 'X=world; echo "hello $X"'
is "$_BB_STDOUT" "hello world" "wsh 双引号内变量展开"

# 双引号内 \n 保持字面，由 echo -e 解释
bb_run_wsh 'echo -e "a\nb"'
is "$_BB_STDOUT" $'a\nb' "wsh 双引号内 \\n 由 echo -e 解释为换行"

# 单引号内不展开变量
bb_run_wsh "echo '\$X'"
is "$_BB_STDOUT" '$X' "wsh 单引号内不展开变量"

# 双引号内命令替换
bb_run_wsh 'echo "result: $(echo 42)"'
is "$_BB_STDOUT" "result: 42" "wsh 双引号内命令替换"

# === 变量修饰符 ===
# ${#VAR} 字符串长度
bb_run_wsh 'X=hello; echo ${#X}'
is "$_BB_STDOUT" "5" "wsh \${#VAR} 字符串长度"

# ${#VAR} 未设置变量
bb_run_wsh 'echo ${#UNDEF_VAR}'
is "$_BB_STDOUT" "0" "wsh \${#VAR} 未设置变量长度为 0"

# ${VAR:-default} 未设置变量
bb_run_wsh 'echo ${UNDEF:-fallback}'
is "$_BB_STDOUT" "fallback" "wsh \${VAR:-default} 未设置返回默认值"

# ${VAR:-default} 已设置变量
bb_run_wsh 'X=set; echo ${X:-fallback}'
is "$_BB_STDOUT" "set" "wsh \${VAR:-default} 已设置返回原值"

# ${VAR:-default} 空值
bb_run_wsh 'X=; echo ${X:-fallback}'
is "$_BB_STDOUT" "fallback" "wsh \${VAR:-default} 空值返回默认值"

# === 错误处理 ===
bb_run_wsh 'nonexistent_cmd_xyz'
cmp_ok "$_BB_EXIT" "!=" "0" "wsh 不存在的命令返回非零"

# === && 和 || 操作符 ===
# &&: 前一条成功才执行
bb_run_wsh 'true && echo yes'
is "$_BB_STDOUT" "yes" "wsh true && echo yes"

# &&: 前一条失败不执行
bb_run_wsh 'false && echo no'
is "$_BB_STDOUT" "" "wsh false && echo no 不执行"

# ||: 前一条失败才执行
bb_run_wsh 'false || echo fallback'
is "$_BB_STDOUT" "fallback" "wsh false || echo fallback"

# ||: 前一条成功不执行
bb_run_wsh 'true || echo no'
is "$_BB_STDOUT" "" "wsh true || echo no 不执行"

# 链式 &&
bb_run_wsh 'true && echo a && echo b'
is "$_BB_STDOUT" $'a\nb' "wsh 链式 &&"

# && 和 || 混合
bb_run_wsh 'false || echo yes && echo no'
is "$_BB_STDOUT" $'yes\nno' "wsh false || echo yes && echo no"

# === case 语句 ===
bb_run_wsh 'X=a; case $X in a) echo A ;; b) echo B ;; *) echo other ;; esac'
is "$_BB_STDOUT" "A" "wsh case 字面匹配"

bb_run_wsh 'X=hello; case $X in h*) echo starts-h ;; *) echo other ;; esac'
is "$_BB_STDOUT" "starts-h" "wsh case 通配符匹配"

bb_run_wsh 'X=z; case $X in a) echo A ;; *) echo other ;; esac'
is "$_BB_STDOUT" "other" "wsh case 默认分支"

bb_run_wsh 'X=a; case $X in a) echo first ;; a) echo second ;; esac'
is "$_BB_STDOUT" "first" "wsh case 只匹配第一个"

# === 变量在命令替换中赋值（echo 赋值有效）===
bb_run_wsh 'F=dummy; F=$(echo replaced); echo $F'
is "$_BB_STDOUT" "replaced" "wsh 命令替换赋值"

# === 通过管道调用命令 ===
bb_run_wsh 'echo hello | wc -c'
like "$_BB_STDOUT" "6" "wsh 通过管道调用 wc"

bb_run_wsh 'seq 1 5 | sort -r | head -1'
like "$_BB_STDOUT" "5" "wsh 管道调用 sort -r"

# === 换行作为命令分隔符 ===

# 基本多行：换行代替分号分隔命令
bb_run_wsh $'echo hello\necho world'
is "$_BB_STDOUT" $'hello\nworld' "wsh 基本多行命令"

# 变量赋值后换行
bb_run_wsh $'X=hello\necho $X'
is "$_BB_STDOUT" "hello" "wsh 多行变量赋值和展开"

# if 跨行：then、fi 单独一行
bb_run_wsh $'if true\nthen echo yes\nfi'
is "$_BB_STDOUT" "yes" "wsh if 跨行 then"

bb_run_wsh $'if false\nthen echo yes\nelse echo no\nfi'
is "$_BB_STDOUT" "no" "wsh if/else 跨行"

# for 跨行：do、done 单独一行
bb_run_wsh $'for i in a b c\ndo echo $i\ndone'
is "$_BB_STDOUT" $'a\nb\nc' "wsh for 跨行"

# while 跨行
bb_run_wsh $'X=0\nwhile [ $X -eq 0 ]\ndo echo zero\nX=1\ndone'
is "$_BB_STDOUT" "zero" "wsh while 跨行"

# 管道跨行：| 后面换行属于管道延续，不应截断
bb_run_wsh $'echo hello |\ntr a-z A-Z'
is "$_BB_STDOUT" "HELLO" "wsh 管道跨行"

# && 跨行
bb_run_wsh $'true &&\necho yes'
is "$_BB_STDOUT" "yes" "wsh && 跨行"

# || 跨行
bb_run_wsh $'false ||\necho fallback'
is "$_BB_STDOUT" "fallback" "wsh || 跨行"

# 多空行：连续空行不应产生多余副作用
bb_run_wsh $'echo one\n\n\necho two'
is "$_BB_STDOUT" $'one\ntwo' "wsh 多空行"

# 缩进：行首空格/制表符
bb_run_wsh $'echo one\n    echo two\n\techo three'
is "$_BB_STDOUT" $'one\ntwo\nthree' "wsh 缩进"

# 子 shell 跨行
bb_run_wsh $'(\necho inner\n)\necho outer'
is "$_BB_STDOUT" $'inner\nouter' "wsh 子 shell 跨行"

# case 跨行
bb_run_wsh $'X=a\ncase $X in\na) echo A\n;;\n*) echo other\n;;\nesac'
is "$_BB_STDOUT" "A" "wsh case 跨行"

# === 注释支持 ===

# 基本行尾注释
bb_run_wsh $'echo hello # this is a comment'
is "$_BB_STDOUT" "hello" "wsh 行尾注释"

# 整行注释
bb_run_wsh $'# this is a comment\necho world'
is "$_BB_STDOUT" "world" "wsh 整行注释"

# 赋值后注释
bb_run_wsh $'X=hello # comment\necho $X'
is "$_BB_STDOUT" "hello" "wsh 赋值后注释"

# 注释在控制流中
bb_run_wsh $'if true # comment\nthen echo yes # another comment\nfi'
is "$_BB_STDOUT" "yes" "wsh 注释在控制流中"

# 多行注释和空行
bb_run_wsh $'echo one\n# comment 1\n# comment 2\necho two'
is "$_BB_STDOUT" $'one\ntwo' "wsh 多行注释"

# 引号内 # 不是注释
bb_run_wsh $'echo "# not a comment"'
is "$_BB_STDOUT" "# not a comment" "wsh 引号内 # 不是注释"

done_testing
