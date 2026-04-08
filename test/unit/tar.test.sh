#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 15

# 创建测试目录结构
mkdir -p "$TMPDIR/srcdir/sub"
mkfile "srcdir/file1.txt" "file one content"
mkfile "srcdir/file2.txt" "file two content"
mkfile "srcdir/sub/file3.txt" "subdirectory file content"

# tar cf 创建归档
bb_run tar cf "$TMPDIR/archive.tar" -C "$TMPDIR" srcdir
is "$_BB_EXIT" "0" "tar cf 创建归档成功"
ok "[ -f $TMPDIR/archive.tar ]" "tar 归档文件存在"

# tar tf 列出内容
bb_run tar tf "$TMPDIR/archive.tar"
is "$_BB_EXIT" "0" "tar tf 列出内容成功"
like "$_BB_STDOUT" "srcdir/file1.txt" "tar tf 包含 file1.txt"
like "$_BB_STDOUT" "srcdir/file2.txt" "tar tf 包含 file2.txt"
like "$_BB_STDOUT" "srcdir/sub/file3.txt" "tar tf 包含子目录文件"

# tar xf 提取
mkdir -p "$TMPDIR/extract1"
bb_run tar xf "$TMPDIR/archive.tar" -C "$TMPDIR/extract1"
is "$_BB_EXIT" "0" "tar xf 提取成功"
is "$(cat "$TMPDIR/extract1/srcdir/file1.txt")" "file one content" "tar xf 提取文件内容正确"

# tar czf gzip 压缩归档需要 fork+pipe，WASI 不支持
bb_run tar czf "$TMPDIR/archive.tar.gz" -C "$TMPDIR" srcdir
cmp_ok "$_BB_EXIT" "!=" "0" "tar czf 因 pipe 限制失败"

# 提取 gzip 压缩归档同样需要 pipe，跳过
mkdir -p "$TMPDIR/extract2"
skip "tar xzf 提取 gzip 归档（依赖 czf 成功）"
skip "tar xzf 提取内容验证（依赖 czf 成功）"

# tar cjf bzip2 压缩归档同样需要 fork+pipe
bb_run tar cjf "$TMPDIR/archive.tar.bz2" -C "$TMPDIR" srcdir
cmp_ok "$_BB_EXIT" "!=" "0" "tar cjf 因 pipe 限制失败"

# tar 不存在的归档
bb_run tar xf "$TMPDIR/nonexistent.tar"
cmp_ok "$_BB_EXIT" "!=" "0" "tar xf 不存在的归档返回非零"

# 提取特定文件
mkdir -p "$TMPDIR/extract3"
bb_run tar xf "$TMPDIR/archive.tar" -C "$TMPDIR/extract3" "srcdir/file1.txt"
is "$_BB_EXIT" "0" "tar xf 提取特定文件成功"
ok "[ -f $TMPDIR/extract3/srcdir/file1.txt ]" "tar xf 特定文件已提取"

done_testing
