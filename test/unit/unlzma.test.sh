#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 3

# unlzma = lzma -d，和 unxz 同理

# unlzma 不存在的文件
bb_run unlzma "$TMPDIR/nonexistent.lzma"
cmp_ok "$_BB_EXIT" "!=" "0" "unlzma 不存在的文件返回非零"

# unlzma 无参数
bb_run unlzma
cmp_ok "$_BB_EXIT" "!=" "0" "unlzma 无参数返回非零"

# unlzma 无参数不崩溃
bb_run unlzma --help 2>/dev/null
ok "unlzma 不崩溃"

done_testing
