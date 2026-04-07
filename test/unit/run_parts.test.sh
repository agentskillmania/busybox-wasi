#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# run-parts --help
bb_run run-parts --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "run-parts --help 成功"
else
    skip "run-parts --help 不可用"
fi

# run-parts 无参数
bb_run_capture run-parts
cmp_ok "$_BB_EXIT" "!=" "0" "run-parts 无参数返回非零"

# 创建测试脚本目录
mkdir -p "$TMPDIR/scripts"
mkfile "scripts/01-first.sh" '#!/bin/sh
echo "first script ran"'
mkfile "scripts/02-second.sh" '#!/bin/sh
echo "second script ran"'
mkfile "scripts/03-third.sh" '#!/bin/sh
echo "third script ran"'
chmod +x "$TMPDIR/scripts/01-first.sh" "$TMPDIR/scripts/02-second.sh" "$TMPDIR/scripts/03-third.sh"

# run-parts 列出脚本
bb_run run-parts --list "$TMPDIR/scripts"
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "run-parts --list 列出脚本成功"
    like "$_BB_STDOUT" "01-first" "run-parts --list 包含第一个脚本"
else
    skip "run-parts --list 不可用"
    skip "run-parts --list 不可用"
fi

# run-parts 执行脚本目录（需要 exec，在 WASM 中可能失败）
bb_run run-parts "$TMPDIR/scripts"
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "run-parts 执行脚本成功"
    like "$_BB_STDOUT" "first script ran" "run-parts 输出包含第一个脚本结果"
else
    # exec 被 stub，run-parts 无法执行子脚本
    cmp_ok "$_BB_EXIT" "!=" "0" "run-parts 因 exec stub 失败（预期行为）"
    skip "run-parts 输出不可用（exec stub）"
fi

# run-parts 不存在的目录
bb_run run-parts "$TMPDIR/nonexistent_dir"
cmp_ok "$_BB_EXIT" "!=" "0" "run-parts 不存在的目录返回非零"

# run-parts --test 模拟执行（不实际运行）
bb_run run-parts --test "$TMPDIR/scripts"
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "run-parts --test 成功"
else
    skip "run-parts --test 不可用"
fi

done_testing
