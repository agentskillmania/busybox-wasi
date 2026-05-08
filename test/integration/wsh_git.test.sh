#!/bin/bash
# wsh → git detailed integration test
#
# Test libgit2 workflow in wsh. Uses `git -C <path>` for repo-relative
# commands because the component model gives each guest its own WASI
# cwd — wsh's chdir() is invisible to the git guest component.

source "$(dirname "$0")/../helper.sh"

plan 20

setup

REPO="$_WASM_DIR/test_repo"
GIT="git -C $REPO -c user.name=Test -c user.email=test@test.com"

# ==================== Basic commands ====================

bb_run_wsh 'git --version'
like "$_BB_STDOUT" "git.*version" "git --version"

# ==================== Init repo ====================
# Use explicit path (component model: guest has separate cwd)

bb_run_wsh "mkdir $REPO && git init $REPO"
cmp_ok "$_BB_EXIT" "==" "0" "git init succeeds"
like "$_BB_STDOUT" "Initialized" "git init output"

# ==================== Empty repo status ====================

bb_run_wsh "git -C $REPO status"
cmp_ok "$_BB_EXIT" "==" "0" "git status empty repo"

bb_run_wsh "git -C $REPO branch"
cmp_ok "$_BB_EXIT" "==" "0" "git branch empty repo"

# ==================== Add files ====================

bb_run_wsh "echo 'hello git' > $REPO/readme.txt && git -C $REPO add readme.txt"
cmp_ok "$_BB_EXIT" "==" "0" "git add single file"

# ==================== Commit ====================

bb_run_wsh "$GIT commit -m 'initial commit'"
cmp_ok "$_BB_EXIT" "==" "0" "git commit"

bb_run_wsh "git -C $REPO log --oneline"
like "$_BB_STDOUT" "initial commit" "git log shows commit"

bb_run_wsh "git -C $REPO log --oneline"
like "$_BB_STDOUT" "initial commit" "git log no-pager"

# ==================== Multi-file operations ====================

bb_run_wsh "echo 'file1' > $REPO/a.txt && echo 'file2' > $REPO/b.txt && git -C $REPO add a.txt b.txt && $GIT commit -m 'add two files'"
cmp_ok "$_BB_EXIT" "==" "0" "git add and commit multiple files"

bb_run_wsh "git -C $REPO log --oneline"
like "$_BB_STDOUT" "add two files" "git log multiple commits"

# ==================== Pipe and compose ====================

bb_run_wsh "git -C $REPO --version | cat"
like "$_BB_STDOUT" "git.*version" "git through pipe"

bb_run_wsh "git -C $REPO log --oneline | wc -l"
cmp_ok "$_BB_EXIT" "==" "0" "git log pipe to wc"

# ==================== Modify and recommit ====================

bb_run_wsh "echo 'modified' >> $REPO/readme.txt && git -C $REPO add readme.txt && $GIT commit -m 'modify readme'"
cmp_ok "$_BB_EXIT" "==" "0" "git modify and commit"

bb_run_wsh "git -C $REPO log --oneline | head -1"
like "$_BB_STDOUT" "modify readme" "git log after modification"

# ==================== Error scenarios ====================

bb_run_wsh "cd /tmp && mkdir _no_git && cd _no_git && git status"
cmp_ok "$_BB_EXIT" "!=" "0" "git status outside repo fails"

bb_run_wsh "mkdir /tmp/_empty_git && git init /tmp/_empty_git && git -C /tmp/_empty_git log"
cmp_ok "$_BB_EXIT" "!=" "0" "git log with no commits fails"

# ==================== Redirect output ====================

bb_run_wsh "git -C $REPO --version > /tmp/_git_ver.txt && cat /tmp/_git_ver.txt"
like "$_BB_STDOUT" "git.*version" "git redirect to file"

bb_run_wsh "git -C $REPO log --oneline > /tmp/_git_log.txt && wc -l /tmp/_git_log.txt"
cmp_ok "$_BB_EXIT" "==" "0" "git log redirect to file"

# ==================== CWD propagation ====================

bb_run_wsh "cd $REPO && git status"
cmp_ok "$_BB_EXIT" "==" "0" "git status after cd (cwd propagation)"

# ==================== Cleanup ====================

rm -f /tmp/_git_ver.txt /tmp/_git_log.txt
rm -rf /tmp/_no_git /tmp/_empty_git

done_testing
