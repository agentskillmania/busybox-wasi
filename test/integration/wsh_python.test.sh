#!/bin/bash
# wsh → python 详细集成测试
#
# 测试 MicroPython 在 wsh 中的完整功能。

source "$(dirname "$0")/../helper.sh"

plan 30

setup

# ==================== 基本调用 ====================

bb_run_wsh 'python -c "print(42)"'
is "$_BB_STDOUT" "42" "python basic print"

bb_run_wsh 'python -c "print(\"hello world\")"'
is "$_BB_STDOUT" "hello world" "python print string"

# ==================== sys.argv ====================

bb_run_wsh 'python -c "import sys; print(sys.argv)"'
like "$_BB_STDOUT" "\['-c'\]" "python argv with -c"

bb_run_wsh 'python "import sys; print(len(sys.argv))"'
is "$_BB_STDOUT" "1" "python single arg len"

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

bb_run_wsh 'python -c "import urllib; print(\"urllib ok\")"'
is "$_BB_STDOUT" "urllib ok" "python urllib module"

# requests 是 frozen 的第三方模块
bb_run_wsh 'python -c "import requests; print(\"requests ok\")"'
is "$_BB_STDOUT" "requests ok" "python requests module"

# ==================== 算术和逻辑 ====================

bb_run_wsh 'python -c "print(1 + 2 * 3)"'
is "$_BB_STDOUT" "7" "python arithmetic precedence"

bb_run_wsh 'python -c "print(10 // 3)"'
is "$_BB_STDOUT" "3" "python floor division"

bb_run_wsh 'python -c "print(2 ** 10)"'
is "$_BB_STDOUT" "1024" "python power"

# ==================== 异常和返回值 ====================

bb_run_wsh 'python -c "import sys; sys.exit(0)"'
cmp_ok "$_BB_EXIT" "==" "0" "python exit 0"

bb_run_wsh 'python -c "import sys; sys.exit(1)"'
cmp_ok "$_BB_EXIT" "==" "1" "python exit 1"

bb_run_wsh 'python -c "import sys; sys.exit(42)"'
cmp_ok "$_BB_EXIT" "==" "42" "python exit 42"

bb_run_wsh 'python -c "raise ValueError(\"test\")"'
cmp_ok "$_BB_EXIT" "!=" "0" "python exception non-zero"

# ==================== 管道和重定向 ====================

bb_run_wsh 'python -c "print(\"pipe test\")" | cat'
is "$_BB_STDOUT" "pipe test" "python pipe to cat"

bb_run_wsh 'python -c "print(\"hello\")" | wc -l'
like "$_BB_STDOUT" "1" "python pipe to wc"

bb_run_wsh 'python -c "print(\"redirect\")" > /tmp/_py_redir.txt; cat /tmp/_py_redir.txt'
is "$_BB_STDOUT" "redirect" "python redirect to file"

# ==================== 多语句（分号分隔） ====================

bb_run_wsh 'python -c "x=1; y=2; print(x+y)"'
is "$_BB_STDOUT" "3" "python multi-statement"

bb_run_wsh 'python -c "import os; print(os.getcwd())"'
like "$_BB_STDOUT" "/tmp\|/" "python os.getcwd"

# ==================== python3 别名 ====================

bb_run_wsh 'python3 -c "print(\"alias\")"'
is "$_BB_STDOUT" "alias" "python3 alias works"

# ==================== 复杂表达式 ====================

bb_run_wsh 'python -c "d={\"a\":1,\"b\":2}; print(d[\"a\"]+d[\"b\"])"'
is "$_BB_STDOUT" "3" "python dict access"

bb_run_wsh 'python -c "l=[1,2,3]; print(sum(l))"'
is "$_BB_STDOUT" "6" "python list sum"

# ==================== HTTPS（可选，需网络） ====================

# 先用网络标志运行
bb_run_net_wsh 'python -c "import requests; r=requests.get(\"https://httpbin.org/get\", timeout=5); print(r.status_code)"' 2>/dev/null || true
if [ "$_BB_EXIT" = "0" ] && [ -n "$_BB_STDOUT" ]; then
	like "$_BB_STDOUT" "200" "python https request"
else
	ok "python https request skipped (no network)"
fi

# ==================== 清理 ====================

rm -f /tmp/_py_redir.txt /tmp/_wsh_py_test.txt

done_testing
