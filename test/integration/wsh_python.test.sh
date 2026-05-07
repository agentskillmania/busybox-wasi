#!/bin/bash
# wsh → python 详细集成测试
#
# 测试 MicroPython 在 wsh 中的完整功能。

source "$(dirname "$0")/../helper.sh"

plan 23

setup

# ==================== 基本调用 ====================

bb_run_wsh 'python -c "print(42)"'
is "$_BB_STDOUT" "42" "python basic print"

bb_run_wsh 'python -c "print(\"hello world\")"'
is "$_BB_STDOUT" "hello world" "python print string"

# ==================== sys.argv ====================

bb_run_wsh 'python -c "import sys; print(sys.argv)"'
like "$_BB_STDOUT" "python.*-c" "python argv with -c"

bb_run_wsh 'python -c "import sys; print(len(sys.argv))"'
is "$_BB_STDOUT" "3" "python argv length is 3"

# ==================== 模块可用性（frozen modules） ====================

bb_run_wsh 'python -c "import ssl; print(\"ssl ok\")"'
is "$_BB_STDOUT" "ssl ok" "python ssl module"

bb_run_wsh 'python -c "import asyncio; print(\"asyncio ok\")"'
is "$_BB_STDOUT" "asyncio ok" "python asyncio module"

bb_run_wsh 'python -c "import gzip; print(\"gzip ok\")"'
is "$_BB_STDOUT" "gzip ok" "python gzip module"

bb_run_wsh 'python -c "import shutil; print(\"shutil ok\")"'
is "$_BB_STDOUT" "shutil ok" "python shutil module"

bb_run_wsh 'python -c "import tempfile; print(\"tempfile ok\")"'
is "$_BB_STDOUT" "tempfile ok" "python tempfile module"

bb_run_wsh 'python -c "import pathlib; print(\"pathlib ok\")"'
is "$_BB_STDOUT" "pathlib ok" "python pathlib module"

# requests is a frozen third-party module
bb_run_wsh 'python -c "import requests; print(\"requests ok\")"'
is "$_BB_STDOUT" "requests ok" "python requests module"

# ==================== 算术和逻辑 ====================

bb_run_wsh 'python -c "print(1 + 2 * 3)"'
is "$_BB_STDOUT" "7" "python arithmetic precedence"

bb_run_wsh 'python -c "print(10 // 3)"'
is "$_BB_STDOUT" "3" "python floor division"

bb_run_wsh 'python -c "print(2 ** 10)"'
is "$_BB_STDOUT" "1024" "python power"

# ==================== Exception handling ====================
# Note: MicroPython treats sys.exit() as an uncaught exception (SystemExit),
# so exec_python_code() returns exit code 1 for all sys.exit() calls.

bb_run_wsh 'python -c "raise ValueError(\"test\")"'
cmp_ok "$_BB_EXIT" "!=" "0" "python exception non-zero"

# ==================== Pipeline and redirection ====================

bb_run_wsh 'python -c "print(\"pipe test\")" | cat'
is "$_BB_STDOUT" "pipe test" "python pipe to cat"

bb_run_wsh 'python -c "print(\"redirect\")" > /tmp/_py_redir.txt; cat /tmp/_py_redir.txt'
is "$_BB_STDOUT" "redirect" "python redirect to file"

# ==================== 多语句（分号分隔） ====================

bb_run_wsh 'python -c "x=1; y=2; print(x+y)"'
is "$_BB_STDOUT" "3" "python multi-statement"

bb_run_wsh 'python -c "import os; print(os.getcwd())"'
is "$_BB_STDOUT" "/" "python os.getcwd returns root"

# ==================== python3 别名 ====================

bb_run_wsh 'python3 -c "print(\"alias\")"'
is "$_BB_STDOUT" "alias" "python3 alias works"

# ==================== 复杂表达式 ====================

bb_run_wsh 'python -c "d={\"a\":1,\"b\":2}; print(d[\"a\"]+d[\"b\"])"'
is "$_BB_STDOUT" "3" "python dict access"

bb_run_wsh 'python -c "l=[1,2,3]; print(sum(l))"'
is "$_BB_STDOUT" "6" "python list sum"

# ==================== HTTPS ====================
# Network-dependent test: skip if external network is unavailable

bb_run_net_wsh 'python -c "import requests; r=requests.get(\"https://httpbin.org/get\", timeout=10); print(r.status_code)"'
if [[ "$_BB_EXIT" == "0" ]]; then
    like "$_BB_STDOUT" "200" "python https request"
else
    skip "python https request (network unavailable)"
fi

# ==================== 清理 ====================

rm -f /tmp/_py_redir.txt /tmp/_wsh_py_test.txt

done_testing
