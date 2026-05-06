#!/bin/bash
# wsh → git 详细集成测试
#
# 测试 libgit2 在 wsh 中的完整工作流。

source "$(dirname "$0")/../helper.sh"

plan 28

setup

REPO="$_WASM_DIR/test_repo"

# ==================== 基本命令 ====================

bb_run_wsh 'git --version'
like "$_BB_STDOUT" "git version" "git --version"

# ==================== 初始化仓库 ====================

bb_run_wsh "mkdir -p $REPO && cd $REPO && git init"
cmp_ok "$_BB_EXIT" "==" "0" "git init"
like "$_BB_STDOUT" "Initialized\|init" "git init output"

# ==================== 空仓库状态 ====================

bb_run_wsh "cd $REPO && git status"
cmp_ok "$_BB_EXIT" "==" "0" "git status empty repo"

bb_run_wsh "cd $REPO && git branch"
cmp_ok "$_BB_EXIT" "==" "0" "git branch empty repo"

# ==================== 添加文件 ====================

bb_run_wsh "cd $REPO && echo 'hello git' > readme.txt && git add readme.txt"
cmp_ok "$_BB_EXIT" "==" "0" "git add single file"

bb_run_wsh "cd $REPO && git status"
like "$_BB_STDOUT" "readme.txt" "git status shows tracked file"

# ==================== 提交 ====================

bb_run_wsh "cd $REPO && git commit -m 'initial commit'"
cmp_ok "$_BB_EXIT" "==" "0" "git commit"

bb_run_wsh "cd $REPO && git log --oneline"
like "$_BB_STDOUT" "initial commit" "git log shows commit"

bb_run_wsh "cd $REPO && git --no-pager log"
like "$_BB_STDOUT" "initial commit" "git log no-pager"

# ==================== 多文件操作 ====================

bb_run_wsh "cd $REPO && echo 'file1' > a.txt && echo 'file2' > b.txt && git add a.txt b.txt"
cmp_ok "$_BB_EXIT" "==" "0" "git add multiple files"

bb_run_wsh "cd $REPO && git commit -m 'add two files'"
cmp_ok "$_BB_EXIT" "==" "0" "git commit multiple files"

bb_run_wsh "cd $REPO && git log --oneline"
like "$_BB_STDOUT" "add two files" "git log multiple commits"

# ==================== 管道和组合 ====================

bb_run_wsh "cd $REPO && git --version | cat"
like "$_BB_STDOUT" "git version" "git through pipe"

bb_run_wsh "cd $REPO && git log --oneline | wc -l"
cmp_ok "$_BB_EXIT" "==" "0" "git log pipe to wc"

bb_run_wsh "cd $REPO && git status; git branch"
cmp_ok "$_BB_EXIT" "==" "0" "git status and branch sequence"

# ==================== 修改和再次提交 ====================

bb_run_wsh "cd $REPO && echo 'modified' >> readme.txt && git add readme.txt && git commit -m 'modify readme'"
cmp_ok "$_BB_EXIT" "==" "0" "git modify and commit"

bb_run_wsh "cd $REPO && git log --oneline | head -1"
like "$_BB_STDOUT" "modify readme" "git log after modification"

# ==================== 错误场景 ====================

# 无仓库时 git status
bb_run_wsh "cd /tmp && rm -rf _no_git && mkdir _no_git && cd _no_git && git status"
cmp_ok "$_BB_EXIT" "!=" "0" "git status outside repo fails"

# git log 无提交（在新仓库但不提交）
bb_run_wsh "cd /tmp && rm -rf _empty_git && mkdir _empty_git && cd _empty_git && git init && git log"
cmp_ok "$_BB_EXIT" "!=" "0" "git log with no commits fails"

# ==================== 重定向输出 ====================

bb_run_wsh "cd $REPO && git --version > /tmp/_git_ver.txt && cat /tmp/_git_ver.txt"
like "$_BB_STDOUT" "git version" "git redirect to file"

bb_run_wsh "cd $REPO && git log --oneline > /tmp/_git_log.txt && wc -l /tmp/_git_log.txt"
cmp_ok "$_BB_EXIT" "==" "0" "git log redirect to file"

# ==================== 清理 ====================

rm -f /tmp/_git_ver.txt /tmp/_git_log.txt
rm -rf /tmp/_no_git /tmp/_empty_git

done_testing
