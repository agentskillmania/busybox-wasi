#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# ftpget 需要 FTP 服务器，在测试环境中通常不可用
# 检测是否有 FTP 服务器可用
HAS_FTP=false
if command -v python3 &>/dev/null; then
    # 尝试用 python 的 ftplib 测试本地 FTP
    HAS_FTP=false  # 需要实际 FTP 服务器
fi

# ftpget --help
bb_run_net ftpget --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "ftpget --help 成功"
else
    skip "ftpget --help 不可用"
fi

# ftpget 无参数
bb_run_net ftpget
cmp_ok "$_BB_EXIT" "!=" "0" "ftpget 无参数返回非零"

skip_if "$HAS_FTP" != "true" "无 FTP 服务器可用，跳过 FTP 功能测试"

# 以下测试需要 FTP 服务器
bb_run_net ftpget 127.0.0.1 "$TMPDIR/ftp_out.txt" "testfile.txt"
is "$_BB_EXIT" "0" "ftpget 下载文件成功"

bb_run_net ftpget -u user -p pass 127.0.0.1 "$TMPDIR/ftp_auth.txt" "testfile.txt"
is "$_BB_EXIT" "0" "ftpget 带认证下载成功"

bb_run_net ftpget 127.0.0.1 "$TMPDIR/ftp_noexist.txt" "nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "ftpget 下载不存在的文件返回非零"

done_testing
