#!/bin/bash
# wsh_mrsh.test.sh — Comprehensive tests for mrsh-powered wsh
#
# Tests mrsh-specific capabilities: multi-line commands, functions,
# control flow, variable expansion, nested command substitution,
# complex pipelines, and more.
source "$(dirname "$0")/../helper.sh"
plan 49

# === Variable expansion ===

bb_run_wsh 'X=hello; echo $X'
is "$_BB_STDOUT" "hello" "variable assignment and expansion"

bb_run_wsh 'X=hello; Y=$X; echo $Y'
is "$_BB_STDOUT" "hello" "variable assignment from another variable"

bb_run_wsh 'X=hello; echo ${X}world'
is "$_BB_STDOUT" "helloworld" "variable expansion with suffix"

bb_run_wsh 'echo ${X:-default}'
is "$_BB_STDOUT" "default" "default value expansion for unset variable"

bb_run_wsh 'X=set; echo ${X:-default}'
is "$_BB_STDOUT" "set" "default value expansion for set variable"

bb_run_wsh 'X=hello; echo ${#X}'
is "$_BB_STDOUT" "5" "string length operator"

bb_run_wsh 'X=foobar; echo ${X#foo}'
is "$_BB_STDOUT" "bar" "remove smallest prefix"

bb_run_wsh 'X=foobar; echo ${X%bar}'
is "$_BB_STDOUT" "foo" "remove smallest suffix"

# === Command substitution ===

bb_run_wsh 'echo $(echo inner)'
is "$_BB_STDOUT" "inner" "basic command substitution"

bb_run_wsh 'echo $(echo $(echo nested))'
is "$_BB_STDOUT" "nested" "nested command substitution"

bb_run_wsh 'echo $(echo hello | tr a-z A-Z)'
is "$_BB_STDOUT" "HELLO" "command substitution with pipeline"

bb_run_wsh 'X=$(echo captured); echo $X'
is "$_BB_STDOUT" "captured" "assign command substitution result"

bb_run_wsh 'echo "result: $(echo 42)"'
is "$_BB_STDOUT" "result: 42" "command substitution in double quotes"

# === Arithmetic ===

bb_run_wsh 'echo $((1+2))'
is "$_BB_STDOUT" "3" "basic addition"

bb_run_wsh 'echo $((10-3))'
is "$_BB_STDOUT" "7" "basic subtraction"

bb_run_wsh 'echo $((4*5))'
is "$_BB_STDOUT" "20" "basic multiplication"

bb_run_wsh 'echo $((10/3))'
is "$_BB_STDOUT" "3" "integer division"

bb_run_wsh 'echo $(( ))'
is "$_BB_STDOUT" "0" "empty arithmetic expression"

bb_run_wsh 'X=5; echo $((X+3))'
is "$_BB_STDOUT" "8" "arithmetic with variable"

bb_run_wsh 'X=3; Y=4; echo $((X*Y))'
is "$_BB_STDOUT" "12" "arithmetic with two variables"

# === Quoting ===

bb_run_wsh "echo 'single quoted'"
is "$_BB_STDOUT" "single quoted" "single quoted string"

bb_run_wsh 'echo "double quoted"'
is "$_BB_STDOUT" "double quoted" "double quoted string"

bb_run_wsh 'X=world; echo "hello $X"'
is "$_BB_STDOUT" "hello world" "variable expansion in double quotes"

bb_run_wsh "echo 'no \$expansion'"
is "$_BB_STDOUT" 'no $expansion' "no expansion in single quotes"

bb_run_wsh 'echo "a;b"'
is "$_BB_STDOUT" "a;b" "semicolon in quotes not treated as separator"

# === Multi-command (semicolon, newline) ===

bb_run_wsh 'echo one; echo two'
is "$_BB_STDOUT" $'one\ntwo' "semicolon separates commands"

bb_run_wsh $'echo line1\necho line2'
is "$_BB_STDOUT" $'line1\nline2' "newline separates commands"

bb_run_wsh $'X=1\necho $X'
is "$_BB_STDOUT" "1" "variable set on previous line"

bb_run_wsh $'echo a\necho b\necho c'
is "$_BB_STDOUT" $'a\nb\nc' "three commands on separate lines"

# === Pipelines ===

bb_run_wsh 'echo hello | tr a-z A-Z'
is "$_BB_STDOUT" "HELLO" "basic pipeline"

bb_run_wsh 'echo hello world | tr -d " "'
is "$_BB_STDOUT" "helloworld" "pipeline with tr -d"

bb_run_wsh 'printf "banana\napple\ncherry\n" | sort | head -2'
like "$_BB_STDOUT" "apple" "multi-stage pipeline: sort then head"

# === If/then/else ===

bb_run_wsh 'if true; then echo yes; fi'
is "$_BB_STDOUT" "yes" "if true executes then branch"

bb_run_wsh 'if false; then echo yes; else echo no; fi'
is "$_BB_STDOUT" "no" "if false executes else branch"

bb_run_wsh 'X=5; if [ $X -gt 3 ]; then echo big; else echo small; fi'
is "$_BB_STDOUT" "big" "if with test expression"

# === While loop ===

bb_run_wsh 'X=0; while [ $X -lt 3 ]; do echo $X; X=$((X+1)); done'
is "$_BB_STDOUT" $'0\n1\n2' "while loop with counter"

# === For loop ===

bb_run_wsh 'for i in a b c; do echo $i; done'
is "$_BB_STDOUT" $'a\nb\nc' "for loop over words"

bb_run_wsh 'for i in 1 2 3; do echo item_$i; done'
is "$_BB_STDOUT" $'item_1\nitem_2\nitem_3' "for loop with number items"

# === Function definition ===

bb_run_wsh 'greet() { echo hello $1; }; greet world'
is "$_BB_STDOUT" "hello world" "function definition and call"

bb_run_wsh 'add() { echo $(($1+$2)); }; add 3 4'
is "$_BB_STDOUT" "7" "function with arithmetic"

bb_run_wsh 'double() { echo $(($1*2)); }; for i in 1 2 3; do double $i; done'
is "$_BB_STDOUT" $'2\n4\n6' "function called in loop"

# === Case statement ===

bb_run_wsh 'X=b; case $X in a) echo A;; b) echo B;; *) echo other;; esac'
is "$_BB_STDOUT" "B" "case statement matching"

bb_run_wsh 'X=z; case $X in a) echo A;; b) echo B;; *) echo other;; esac'
is "$_BB_STDOUT" "other" "case statement default"

# === Subshell (deep copy) ===

bb_run_wsh 'X=outer; (X=inner; echo $X); echo $X'
is "$_BB_STDOUT" $'inner\nouter' "subshell isolation"

# === Logical operators ===

bb_run_wsh 'true && echo yes'
is "$_BB_STDOUT" "yes" "AND operator: true && cmd"

bb_run_wsh 'false && echo yes'
is "$_BB_STDOUT" "" "AND operator: false && cmd skips"

bb_run_wsh 'false || echo fallback'
is "$_BB_STDOUT" "fallback" "OR operator: false || cmd"

bb_run_wsh 'true || echo fallback'
is "$_BB_STDOUT" "" "OR operator: true || cmd skips"

# === Complex multi-line ===

bb_run_wsh $'if true; then\n  echo line1\n  echo line2\nfi'
is "$_BB_STDOUT" $'line1\nline2' "multi-line if block"

bb_run_wsh $'for i in 1 2 3; do\n  echo num_$i\ndone'
is "$_BB_STDOUT" $'num_1\nnum_2\nnum_3' "multi-line for loop"

done_testing
