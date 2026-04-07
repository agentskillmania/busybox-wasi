#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 9

# dpkg-deb --help
bb_run dpkg-deb --help
is "$_BB_EXIT" "0" "dpkg-deb --help 退出码为 0"
like "$_BB_STDOUT" "dpkg" "dpkg-deb --help 输出包含 dpkg"

# dpkg-deb --version
bb_run dpkg-deb --version
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "dpkg-deb --version 成功"
else
    skip "dpkg-deb --version 不可用"
fi

# dpkg-deb 不存在的文件
bb_run dpkg-deb -I "$TMPDIR/nonexistent.deb"
cmp_ok "$_BB_EXIT" "!=" "0" "dpkg-deb -I 不存在的文件返回非零"

# dpkg-deb -x 不存在的文件
bb_run dpkg-deb -x "$TMPDIR/nonexistent.deb" "$TMPDIR/extract"
cmp_ok "$_BB_EXIT" "!=" "0" "dpkg-deb -x 不存在的文件返回非零"

# 使用 host 工具创建一个简单的 .deb 文件用于测试
if command -v dpkg-deb &>/dev/null; then
    mkdir -p "$TMPDIR/mkdeb/DEBIAN"
    mkdir -p "$TMPDIR/mkdeb/usr/share/doc/testpkg"
    printf 'Package: testpkg\nVersion: 1.0\nArchitecture: all\nMaintainer: test\nDescription: test package\n' > "$TMPDIR/mkdeb/DEBIAN/control"
    printf 'test content' > "$TMPDIR/mkdeb/usr/share/doc/testpkg/readme.txt"
    dpkg-deb -b "$TMPDIR/mkdeb" "$TMPDIR/test.deb" >/dev/null 2>&1
    HAS_DEB=true
else
    HAS_DEB=false
fi

skip_if "$HAS_DEB" != "true" "需要 host dpkg-deb 创建测试 .deb 文件"

# dpkg-deb -I 查看 .deb 信息
bb_run dpkg-deb -I "$TMPDIR/test.deb"
is "$_BB_EXIT" "0" "dpkg-deb -I 查看 deb 信息成功"
like "$_BB_STDOUT" "testpkg" "dpkg-deb -I 输出包含包名"

# dpkg-deb -c 列出内容
bb_run dpkg-deb -c "$TMPDIR/test.deb"
is "$_BB_EXIT" "0" "dpkg-deb -c 列出内容成功"
like "$_BB_STDOUT" "readme.txt" "dpkg-deb -c 包含 readme.txt"

# dpkg-deb -x 提取
mkdir -p "$TMPDIR/deb_extract"
bb_run dpkg-deb -x "$TMPDIR/test.deb" "$TMPDIR/deb_extract"
is "$_BB_EXIT" "0" "dpkg-deb -x 提取成功"
is "$(cat "$TMPDIR/deb_extract/usr/share/doc/testpkg/readme.txt")" "test content" "dpkg-deb -x 提取内容正确"

done_testing
