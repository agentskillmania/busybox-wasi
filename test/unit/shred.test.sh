#!/bin/bash
# shred 在 WASI 下因需要 /dev/zero 而失败
# 测试目标：验证 shred 在 WASI 下返回错误而非静默成功
source "$(dirname "$0")/../helper.sh"
plan 7

# 生成测试文件
file=$(mkfile "secret.txt" "sensitive data here")

# shred 文件 — WASI 下无法打开 /dev/zero，应返回非零
bb_run shred "$file"
cmp_ok "$_BB_EXIT" "!=" "0" "shred 在 WASI 下因无 /dev/zero 返回非零"

# 验证文件内容未被改变（shred 失败不影响文件）
bb_run cat "$file"
is "$_BB_STDOUT" "sensitive data here" "shred 失败后文件内容不变"

# shred -u 删除文件 — WASI 下也应失败
file2=$(mkfile "secret2.txt" "more secrets")
bb_run shred -u "$file2"
cmp_ok "$_BB_EXIT" "!=" "0" "shred -u 在 WASI 下返回非零"

# 验证文件未被删除（shred 失败不应删除文件）
is "$(test -f "$file2" && echo 'exists' || echo 'gone')" "exists" "shred -u 失败后文件仍存在"

# shred -n 指定覆盖次数 — WASI 下应失败
file3=$(mkfile "secret3.txt" "overwrite me")
bb_run shred -n 3 "$file3"
cmp_ok "$_BB_EXIT" "!=" "0" "shred -n 3 在 WASI 下返回非零"

# shred -z 最终覆盖为零 — WASI 下应失败
file4=$(mkfile "secret4.txt" "zero me")
bb_run shred -z "$file4"
cmp_ok "$_BB_EXIT" "!=" "0" "shred -z 在 WASI 下返回非零"

# 无参数应报错（正常行为）
bb_run shred
cmp_ok "$_BB_EXIT" "!=" "0" "shred 无参数返回非零"

done_testing
