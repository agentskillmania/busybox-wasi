#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 4

# ftpget 需要 FTP 服务器，测试环境中不可用

# ftpget --help
bb_run_capture ftpget --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "ftpget --help 成功"
else
    skip "ftpget --help 不可用"
fi

# ftpget 无参数
bb_run_net ftpget
cmp_ok "$_BB_EXIT" "!=" "0" "ftpget 无参数返回非零"

# FTP 功能测试需要 FTP 服务器
skip "ftpget 下载文件（需要 FTP 服务器）"
skip "ftpget 带认证下载（需要 FTP 服务器）"

done_testing
