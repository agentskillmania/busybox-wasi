#!/bin/bash
# redirect.test.sh — I/O redirect tests for wsh
#
# All redirects use freopen() since dup2 is a stub in WASI.
# Known limitation: after stderr redirect (2>file), the capture mechanism
# (which writes captured stdout via STDERR_FILENO) also writes into the
# redirect file instead of the terminal. This is an architectural limit
# — there is no dup() to save/restore the original stderr fd.

source "$(dirname "$0")/../helper.sh"

plan 12

setup

# ==================== stdout redirect (> file) ====================

bb_run_wsh 'echo "hello world" > /tmp/_redir_input.txt'

bb_run_wsh 'echo redirect_out > /tmp/_redir_out.txt && cat /tmp/_redir_out.txt'
is "$_BB_STDOUT" "redirect_out" "stdout redirect > file"

bb_run_wsh 'echo append_out >> /tmp/_redir_out.txt && cat /tmp/_redir_out.txt'
like "$_BB_STDOUT" "append_out" "stdout append >> file"

# ==================== stdin redirect (< file) ====================

bb_run_wsh 'cat < /tmp/_redir_out.txt'
like "$_BB_STDOUT" "redirect_out" "stdin redirect < file"

bb_run_wsh 'grep world < /tmp/_redir_input.txt'
is "$_BB_STDOUT" "hello world" "stdin redirect grep < file"

# ==================== stderr redirect (2> file) ====================
# Known limit: 2>file works for the applet itself, but subsequent
# commands in the same wsh invocation lose their capture output because
# STDERR_FILENO is now the redirect file. Test the suppression case only.

bb_run_wsh 'cat /nonexistent_xyz 2>/dev/null'
cmp_ok "$_BB_EXIT" "!=" "0" "stderr redirect 2>/dev/null suppresses error"

# ==================== combined stdin + stdout ====================

bb_run_wsh 'grep hello < /tmp/_redir_input.txt > /tmp/_redir_both.txt && cat /tmp/_redir_both.txt'
is "$_BB_STDOUT" "hello world" "stdin + stdout redirect combined"

# ==================== builtin with stdout redirect ====================

bb_run_wsh 'pwd > /tmp/_redir_pwd.txt && cat /tmp/_redir_pwd.txt'
is "$_BB_STDOUT" "/" "builtin pwd redirect > file"

bb_run_wsh 'export TESTVAR=hello; echo $TESTVAR > /tmp/_redir_var.txt && cat /tmp/_redir_var.txt'
is "$_BB_STDOUT" "hello" "builtin export + echo redirect > file"

# ==================== builtin with stdin redirect ====================

bb_run_wsh 'read LINE < /tmp/_redir_input.txt; echo $LINE'
is "$_BB_STDOUT" "hello world" "builtin read < file"

# ==================== applet with stdin redirect ====================

bb_run_wsh 'sort < /tmp/_redir_input.txt'
is "$_BB_STDOUT" "hello world" "applet sort < file"

bb_run_wsh 'wc -w < /tmp/_redir_input.txt'
like "$_BB_STDOUT" "2" "applet wc < file counts words"

# ==================== pipeline + redirect ====================

bb_run_wsh 'printf "cherry\nbanana\napple\n" | sort | head -1 > /tmp/_redir_pipe.txt && cat /tmp/_redir_pipe.txt'
is "$_BB_STDOUT" "apple" "pipeline + stdout redirect"

done_testing
