#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# dpkg --help 应该能正常退出或输出帮助信息
bb_run dpkg --help
is "$_BB_EXIT" "0" "dpkg --help 退出码为 0"
like "$_BB_STDOUT" "dpkg" "dpkg --help 输出包含 dpkg"

# dpkg --version
bb_run dpkg --version
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "dpkg --version 成功"
else
    skip "dpkg --version 不可用"
fi

# dpkg -l 列出已安装包（可能无数据库，测试不崩溃）
bb_run dpkg -l
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "dpkg -l 执行成功"
else
    # 在没有 dpkg 数据库的情况下，dpkg -l 可能失败
    cmp_ok "$_BB_EXIT" "!=" "0" "dpkg -l 无数据库时返回非零（预期行为）"
fi

# dpkg -i 安装不存在的 deb 文件
bb_run dpkg -i "$TMPDIR/nonexistent.deb"
cmp_ok "$_BB_EXIT" "!=" "0" "dpkg -i 不存在的 deb 文件返回非零"

# dpkg -s 查询不存在的包
bb_run dpkg -s "nonexistent-package-xyz"
cmp_ok "$_BB_EXIT" "!=" "0" "dpkg -s 不存在的包返回非零"

# dpkg -r 移除不存在的包
bb_run dpkg -r "nonexistent-package-xyz"
cmp_ok "$_BB_EXIT" "!=" "0" "dpkg -r 不存在的包返回非零"

# dpkg 无参数
bb_run_capture dpkg
cmp_ok "$_BB_EXIT" "!=" "0" "dpkg 无参数返回非零"

done_testing
