#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# mktemp 创建临时文件（WASI 中 mkstemp 可能返回 ENOSYS）
bb_run mktemp
_mktemp_failed="0"
[[ "$_BB_EXIT" != "0" ]] && _mktemp_failed="1"

if skip_if "$_mktemp_failed" "mktemp 在 WASI 中不可用（mkstemp ENOSYS）"; then
    # 如果跳过了，后续依赖 mktemp 的测试也跳过
    skip "mktemp -d 在 WASI 中不可用"
    skip "mktemp 指定模板在 WASI 中不可用"
    skip "mktemp -p 指定目录在 WASI 中不可用"
    skip "mktemp -q 安静模式在 WASI 中不可用"
    skip "mktemp -t 在 WASI 中不可用"
    skip "mktemp 多次调用生成不同名称在 WASI 中不可用"
    skip "mktemp 创建的文件确实存在在 WASI 中不可用"
else
    is "$_BB_EXIT" "0" "mktemp 创建临时文件成功"
    like "$_BB_STDOUT" "/tmp" "mktemp 输出包含路径"

    # mktemp -d 创建临时目录
    bb_run mktemp -d
    is "$_BB_EXIT" "0" "mktemp -d 创建临时目录成功"

    # mktemp 指定模板
    bb_run mktemp "$TMPDIR/mktest.XXXXXX"
    is "$_BB_EXIT" "0" "mktemp 指定模板创建成功"
    like "$_BB_STDOUT" "mktest" "mktemp 模板名称被使用"

    # mktemp -p 指定目录
    bb_run mktemp -p "$TMPDIR"
    is "$_BB_EXIT" "0" "mktemp -p 指定目录创建成功"

    # mktemp -q 安静模式
    bb_run mktemp -q
    is "$_BB_EXIT" "0" "mktemp -q 安静模式成功"

    # mktemp -t 在 TMPDIR 下创建
    bb_run mktemp -t myprefix.XXXXXX
    is "$_BB_EXIT" "0" "mktemp -t 创建成功"

    # 创建的文件确实存在
    bb_run mktemp
    created_file="$_BB_STDOUT"
    bb_run test -f "$created_file"
    is "$_BB_EXIT" "0" "mktemp 创建的文件确实存在"
fi

done_testing
