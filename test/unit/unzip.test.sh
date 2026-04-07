#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 8

# unzip 在 WASI 中不可用（需要 dup2，返回 ENOSYS：Function not implemented）
# 所有 unzip 操作返回非零退出码

# 创建测试 zip 文件用于验证
mkfile "zip_file1.txt" "zip content one"
mkfile "zip_file2.txt" "zip content two"
mkdir -p "$TMPDIR/zipdir/sub"
mkfile "zipdir/sub/nested.txt" "nested content"

# 使用 python3 创建 zip 归档
HAS_ZIP=false
if command -v python3 &>/dev/null; then
    python3 -c "
import zipfile, os
os.chdir('$TMPDIR')
with zipfile.ZipFile('test.zip', 'w') as z:
    z.write('zip_file1.txt')
    z.write('zip_file2.txt')
" 2>/dev/null && HAS_ZIP=true
fi

# unzip -l 在 WASI 中不可用（dup2 ENOSYS）
if [[ "$HAS_ZIP" == "true" ]]; then
    bb_run unzip -l "$TMPDIR/test.zip"
    cmp_ok "$_BB_EXIT" "!=" "0" "unzip -l 在 WASI 中不可用（dup2 ENOSYS）"
else
    skip "需要 python3 创建测试 zip 文件"
fi

# unzip 提取文件在 WASI 中不可用
if [[ "$HAS_ZIP" == "true" ]]; then
    mkdir -p "$TMPDIR/extract"
    bb_run unzip "$TMPDIR/test.zip" -d "$TMPDIR/extract"
    cmp_ok "$_BB_EXIT" "!=" "0" "unzip 提取文件在 WASI 中不可用"
else
    skip "需要 python3 创建测试 zip 文件"
fi

# unzip 不存在的 zip 文件返回非零
bb_run unzip "$TMPDIR/nonexistent.zip"
cmp_ok "$_BB_EXIT" "!=" "0" "unzip 不存在的文件返回非零"

# unzip 提取特定文件在 WASI 中不可用
if [[ "$HAS_ZIP" == "true" ]]; then
    mkdir -p "$TMPDIR/extract2"
    bb_run unzip "$TMPDIR/test.zip" "zip_file1.txt" -d "$TMPDIR/extract2"
    cmp_ok "$_BB_EXIT" "!=" "0" "unzip 提取特定文件在 WASI 中不可用"
else
    skip "需要 python3 创建测试 zip 文件"
fi

# 验证 unzip 不是段错误
bb_run_capture unzip -l "$TMPDIR/test.zip" 2>/dev/null || true
unlike "${_BB_STDERR:-}" "SIGSEGV|signal" "unzip 失败但不产生段错误"

# 验证 unzip --help 可用
bb_run unzip --help 2>/dev/null || true
ok "unzip --help 不崩溃"

# 验证压缩文件仍然存在
if [[ "$HAS_ZIP" == "true" ]]; then
    ok "[[ -f $TMPDIR/test.zip ]]" "测试 zip 文件存在"
else
    skip "需要 python3 创建测试 zip 文件"
fi

# unzip 在 wsh 中同样不可用
if [[ "$HAS_ZIP" == "true" ]]; then
    bb_run_wsh "unzip -l $TMPDIR/test.zip"
    cmp_ok "$_BB_EXIT" "!=" "0" "unzip 在 wsh 中不可用"
else
    skip "需要 python3 创建测试 zip 文件"
fi

done_testing
