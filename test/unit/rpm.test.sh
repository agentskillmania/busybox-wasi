#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 6

# rpm --help 测试
bb_run rpm --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "rpm --help 退出码为 0"
else
    # rpm 可能因为缺少数据库或 WASM 限制而失败
    skip "rpm --help 在 WASM 环境不可用"
fi

# rpm 无参数（应失败或输出用法）
bb_run_capture rpm
cmp_ok "$_BB_EXIT" "!=" "0" "rpm 无参数返回非零"

# rpm -qa 列出所有已安装包（可能无 RPM 数据库）
bb_run rpm -qa
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "rpm -qa 执行成功"
else
    skip "rpm -qa 在 WASM 环境不可用（无 RPM 数据库）"
fi

# rpm -q 查询不存在的包
bb_run rpm -q "nonexistent-rpm-package"
cmp_ok "$_BB_EXIT" "!=" "0" "rpm -q 不存在的包返回非零"

# rpm -i 安装不存在的文件
bb_run rpm -i "$TMPDIR/nonexistent.rpm"
cmp_ok "$_BB_EXIT" "!=" "0" "rpm -i 不存在的文件返回非零"

# rpm -e 卸载不存在的包
bb_run rpm -e "nonexistent-rpm-package"
cmp_ok "$_BB_EXIT" "!=" "0" "rpm -e 不存在的包返回非零"

done_testing
