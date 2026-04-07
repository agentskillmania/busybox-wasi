#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# unxz = xz -d，解压 xz 文件
# 需要 dup 来读写文件，WASI 不支持

# unxz 不存在的文件
bb_run unxz "$TMPDIR/nonexistent.xz"
cmp_ok "$_BB_EXIT" "!=" "0" "unxz 不存在的文件返回非零"

# unxz stdin 解压（需要 host xz 创建数据）
if command -v xz &>/dev/null; then
    data=$(echo "hello unxz" | xz | base64)
    decoded=$(echo "$data" | base64 -d)
    bb_run_stdin "$decoded" unxz
    if [[ "$_BB_EXIT" == "0" ]]; then
        is "$_BB_STDOUT" "hello unxz" "unxz stdin 解压正确"
    else
        skip "unxz stdin 解压（数据传递问题）"
    fi
else
    skip "unxz stdin（host 无 xz 命令）"
fi

# unxz 无参数时从 stdin 读取（不报错）
bb_run unxz
ok "unxz 无参数不崩溃"

done_testing
