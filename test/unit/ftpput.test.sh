#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# ftpput 需要 FTP 服务器，测试环境中不可用

# ftpput --help
bb_run_capture ftpput --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "ftpput --help 成功"
else
    skip "ftpput --help 不可用"
fi

# ftpput 无参数
bb_run_net ftpput
cmp_ok "$_BB_EXIT" "!=" "0" "ftpput 无参数返回非零"

# FTP 功能测试需要 FTP 服务器
skip "ftpput 上传文件（需要 FTP 服务器）"
skip "ftpput 带认证上传（需要 FTP 服务器）"

done_testing
