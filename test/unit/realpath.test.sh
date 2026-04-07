#!/bin/bash
source "$(dirname "$0")/../helper.sh"
plan 1

# realpath 需要解析绝对路径，WASI 沙箱无法访问完整文件系统
# 即使传入 --dir=，realpath 仍需要 stat 系统调用来验证路径组件
skip "realpath 在 WASI 中不可用（无法解析绝对路径）"

done_testing
