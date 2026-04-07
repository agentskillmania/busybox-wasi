#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 10

# 创建测试 zip 文件
mkfile "zip_file1.txt" "zip content one"
mkfile "zip_file2.txt" "zip content two"
mkdir -p "$TMPDIR/zipdir/sub"
mkfile "zipdir/sub/nested.txt" "nested content"

# 使用 host 的 zip 或 python 创建 zip 归档
if command -v zip &>/dev/null; then
    (cd "$TMPDIR" && zip "$TMPDIR/test.zip" zip_file1.txt zip_file2.txt) >/dev/null 2>&1
    HAS_ZIP=true
elif command -v python3 &>/dev/null; then
    python3 -c "
import zipfile, os
os.chdir('$TMPDIR')
with zipfile.ZipFile('test.zip', 'w') as z:
    z.write('zip_file1.txt')
    z.write('zip_file2.txt')
" 2>/dev/null
    HAS_ZIP=true
else
    HAS_ZIP=false
fi

skip_if "$HAS_ZIP" != "true" "需要 zip 或 python3 创建测试 zip 文件"

# unzip -l 列出内容
bb_run unzip -l "$TMPDIR/test.zip"
is "$_BB_EXIT" "0" "unzip -l 列出 zip 内容成功"
like "$_BB_STDOUT" "zip_file1.txt" "unzip -l 包含 zip_file1.txt"
like "$_BB_STDOUT" "zip_file2.txt" "unzip -l 包含 zip_file2.txt"

# unzip 提取到目录
mkdir -p "$TMPDIR/extract"
bb_run unzip "$TMPDIR/test.zip" -d "$TMPDIR/extract"
is "$_BB_EXIT" "0" "unzip 提取文件成功"
is "$(cat "$TMPDIR/extract/zip_file1.txt")" "zip content one" "unzip 提取文件内容正确"
is "$(cat "$TMPDIR/extract/zip_file2.txt")" "zip content two" "unzip 提取第二个文件内容正确"

# unzip 不存在的 zip 文件
bb_run unzip "$TMPDIR/nonexistent.zip"
cmp_ok "$_BB_EXIT" "!=" "0" "unzip 不存在的文件返回非零"

# unzip 提取特定文件
mkdir -p "$TMPDIR/extract2"
bb_run unzip "$TMPDIR/test.zip" "zip_file1.txt" -d "$TMPDIR/extract2"
is "$_BB_EXIT" "0" "unzip 提取特定文件成功"
ok "[ -f $TMPDIR/extract2/zip_file1.txt ]" "unzip 特定文件已提取"
ok "[ ! -f $TMPDIR/extract2/zip_file2.txt ]" "unzip 未提取非指定文件"

done_testing
