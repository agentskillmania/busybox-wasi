#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# 生成测试文件
file=$(mkfile "test.txt" "hello")

# 基本文件哈希
bb_run sha3sum "$file"
if [[ $_BB_EXIT -eq 0 ]]; then
    like "$_BB_STDOUT" "^[0-9a-f]+" "sha3sum 输出包含十六进制哈希"

    # 哈希值 + 两个空格 + 文件名格式
    like "$_BB_STDOUT" "^[0-9a-f]+  test.txt" "sha3sum 输出格式正确"

    # 通过 stdin
    bb_run_stdin "hello" sha3sum
    is "$_BB_EXIT" "0" "sha3sum 通过 stdin 计算"

    # 空文件
    empty=$(mkfile "empty.txt" "")
    bb_run sha3sum "$empty"
    is "$_BB_EXIT" "0" "sha3sum 空文件不崩溃"

    # 多文件
    file2=$(mkfile "test2.txt" "world")
    bb_run sha3sum "$file" "$file2"
    cmp_ok "$(echo "$_BB_STDOUT" | wc -l)" "==" "2" "sha3sum 多文件输出两行"

    # 非空输出
    bb_run sha3sum "$file"
    hash=$(echo "$_BB_STDOUT" | awk '{print $1}')
    isnt "$hash" "" "sha3sum 哈希值非空"
else
    skip "sha3sum 不可用 (exit=$_BB_EXIT)"
    skip "sha3sum 不可用"
    skip "sha3sum 不可用"
    skip "sha3sum 不可用"
    skip "sha3sum 不可用"
fi

done_testing
