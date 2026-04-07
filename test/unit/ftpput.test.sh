#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 5

# ftpput 需要 FTP 服务器，在测试环境中通常不可用
HAS_FTP=false

# ftpput --help
bb_run_net ftpput --help
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "ftpput --help 成功"
else
    skip "ftpput --help 不可用"
fi

# ftpput 无参数
bb_run_net ftpput
cmp_ok "$_BB_EXIT" "!=" "0" "ftpput 无参数返回非零"

skip_if "$HAS_FTP" != "true" "无 FTP 服务器可用，跳过 FTP 上传测试"

# 以下测试需要 FTP 服务器
mkfile "upload.txt" "ftp upload test content"

bb_run_net ftpput 127.0.0.1 "upload.txt" "$TMPDIR/upload.txt"
is "$_BB_EXIT" "0" "ftpput 上传文件成功"

bb_run_net ftpput -u user -p pass 127.0.0.1 "upload_auth.txt" "$TMPDIR/upload.txt"
is "$_BB_EXIT" "0" "ftpput 带认证上传成功"

bb_run_net ftpput 127.0.0.1 "upload.txt" "$TMPDIR/nonexistent.txt"
cmp_ok "$_BB_EXIT" "!=" "0" "ftpput 上传不存在的文件返回非零"

done_testing
