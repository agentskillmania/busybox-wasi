#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 生成测试文件
file=$(mkfile "test.txt" "hello world")

# 基本调用
bb_run crc32 "$file"
if [[ $_BB_EXIT -eq 0 ]]; then
    like "$_BB_STDOUT" "^[0-9a-fA-F]+" "crc32 输出包含十六进制值"

    # 通过 stdin
    bb_run_stdin "hello world" crc32
    is "$_BB_EXIT" "0" "crc32 通过 stdin 计算"

    # 空文件
    empty=$(mkfile "empty.txt" "")
    bb_run crc32 "$empty"
    is "$_BB_EXIT" "0" "crc32 空文件不崩溃"

    # 不同内容产生不同 CRC
    file2=$(mkfile "test2.txt" "different")
    bb_run crc32 "$file2"
    crc2="$_BB_STDOUT"
    bb_run crc32 "$file"
    isnt "$_BB_STDOUT" "$crc2" "crc32 不同内容产生不同值"

    # 输出非空
    bb_run crc32 "$file"
    isnt "$_BB_STDOUT" "" "crc32 输出非空"

    # 退出码为 0
    bb_run crc32 "$file"
    is "$_BB_EXIT" "0" "crc32 退出码为 0"
else
    skip "crc32 不可用 (exit=$_BB_EXIT)"
    skip "crc32 不可用"
    skip "crc32 不可用"
    skip "crc32 不可用"
    skip "crc32 不可用"
fi

done_testing
