#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# dos2unix 原位编辑需要 mkstemp（WASI 不支持），只测 stdin 模式

# dos2unix stdin 转换 CRLF → LF
bb_run_stdin $'hello\r\nworld\r\n' dos2unix
is "$_BB_EXIT" "0" "dos2unix stdin 转换不崩溃"
unlike "$_BB_STDOUT" $'\r' "dos2unix stdin 转换后无 \\r"
like "$_BB_STDOUT" "hello" "dos2unix stdin 转换后内容保留"
like "$_BB_STDOUT" "world" "dos2unix stdin 转换后内容完整"

done_testing
