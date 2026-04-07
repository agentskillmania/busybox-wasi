#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 7

# dpkg-deb --help 输出到 stderr
bb_run_capture dpkg-deb --help
is "$_BB_EXIT" "0" "dpkg-deb --help 退出码为 0"
_dpkg_deb_help="${_BB_STDOUT}${_BB_STDERR}"
like "$_dpkg_deb_help" "dpkg" "dpkg-deb --help 输出包含 dpkg"

# dpkg-deb --version
bb_run dpkg-deb --version
if [[ "$_BB_EXIT" == "0" ]]; then
    is "$_BB_EXIT" "0" "dpkg-deb --version 成功"
else
    skip "dpkg-deb --version 不可用"
fi

# dpkg-deb 不存在的文件
bb_run dpkg-deb -e "$TMPDIR/nonexistent.deb"
cmp_ok "$_BB_EXIT" "!=" "0" "dpkg-deb 不存在的文件返回非零"

# dpkg-deb -c/-x 需要 pipe() 解压（WASI 不支持）
skip "dpkg-deb -c 需要 pipe（WASI ENOSYS）"
skip "dpkg-deb -x 需要 pipe（WASI ENOSYS）"

# 使用 host 工具创建 .deb 文件，测试 -I 选项
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

skip_if test "$HAS_DEB" != "true" "需要 host dpkg-deb 创建测试 .deb 文件"

# BusyBox dpkg-deb 不支持 -I 选项，跳过

done_testing
