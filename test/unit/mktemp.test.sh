#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# mktemp 已实现 mkstemp/mkdtemp，临时文件和目录创建均可用

# 指定模板创建文件
bb_run mktemp "$TMPDIR/mktest.XXXXXX"
is "$_BB_EXIT" "0" "mktemp 指定模板创建成功"
like "$_BB_STDOUT" "mktest" "mktemp 模板名称被使用"

# -d 创建临时目录
bb_run mktemp -d "$TMPDIR/mktestdir.XXXXXX"
is "$_BB_EXIT" "0" "mktemp -d 创建临时目录成功"
like "$_BB_STDOUT" "mktestdir" "mktemp -d 输出包含目录名"

# 验证创建的文件确实存在
created=$($WASMTIME -W exceptions=y --dir="$TMPDIR" busybox.wasm mktemp "$TMPDIR/exist.XXXXXX" 2>/dev/null)
bb_run test -f "$created"
is "$_BB_EXIT" "0" "mktemp 创建的文件确实存在"

# 验证创建的目录确实存在
created_dir=$($WASMTIME -W exceptions=y --dir="$TMPDIR" busybox.wasm mktemp -d "$TMPDIR/existdir.XXXXXX" 2>/dev/null)
bb_run test -d "$created_dir"
is "$_BB_EXIT" "0" "mktemp -d 创建的目录确实存在"

# -p 指定目录
bb_run mktemp -p "$TMPDIR" "prefix.XXXXXX"
is "$_BB_EXIT" "0" "mktemp -p 指定目录创建成功"
like "$_BB_STDOUT" "prefix" "mktemp -p 使用了前缀"

done_testing
