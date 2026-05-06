#!/bin/bash
# Component Model integration tests for busybox-wasi
#
# Tests git and python sub-commands via wsh in the composed WASM binary.
# Requires: wasmtime, wac, and pre-built guest components.
#
# Prerequisites:
#   1. bash ../libgit2/build_component.sh
#   2. bash ../micropython-1.27.0-wasi/ports/wasi/build_component.sh
#   3. ./build_wasm.sh
#
# Usage:
#   bash test/integration/composed.test.sh
source "$(dirname "$0")/../helper.sh"

# ========================= Composed binary setup =========================

_PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
_WASMTIME="${WASMTIME:-$HOME/bin/wasmtime}"
_WASM_FLAGS="-W exceptions=y"

_COMPOSED="$_PROJ_ROOT/busybox.wasm"
_GIT_GUEST="$_PROJ_ROOT/../libgit2/build-component/git-guest.wasm"
_PY_GUEST="$_PROJ_ROOT/../micropython-1.27.0-wasi/ports/wasi/build-component/micropython-guest.wasm"
_HOST_COMP="$_PROJ_ROOT/build/busybox-host.wasm"

# Helper: run command through composed binary via wsh
# Sets: _CO_EXIT, _CO_STDOUT
co_run_wsh() {
	local cmd="$1"
	local tmperr="$_TEST_TMPDIR/_co_stderr.txt"

	_CO_STDOUT=$($_WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" --dir=/tmp \
		"$_COMPOSED" wsh -c "$cmd" 2>"$tmperr" | tr -d '\r') && _CO_EXIT=0 || _CO_EXIT=$?
	local stderr_out
	stderr_out="$(cat "$tmperr" 2>/dev/null | tr -d '\r')" || stderr_out=""
	if [[ -n "$stderr_out" ]]; then
		if [[ -n "$_CO_STDOUT" ]]; then
			_CO_STDOUT="$_CO_STDOUT"$'\n'"$stderr_out"
		else
			_CO_STDOUT="$stderr_out"
		fi
	fi
}

# Helper: run applet directly (not through wsh)
co_run() {
	local stderr_dest="/dev/null"
	[[ "${VERBOSE:-}" == "y" ]] && stderr_dest="/dev/stderr"

	_CO_STDOUT=$($_WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" --dir=/tmp \
		"$_COMPOSED" "$@" 2>"$stderr_dest" | tr -d '\r') && _CO_EXIT=0 || _CO_EXIT=$?
}

# ========================= Build & compose =========================

plan 17

setup

# --- Check prerequisites ---

if [[ ! -x "$_WASMTIME" ]]; then
	for i in $(seq 1 20); do skip "wasmtime not found"; done
	done_testing
	exit 0
fi

# Build host component if missing
if [[ ! -f "$_HOST_COMP" ]]; then
	echo "# Building host component..."
	bash "$_PROJ_ROOT/busybox-wasi/build_wasm.sh" >/dev/null 2>&1
fi

# Build git guest if missing
if [[ ! -f "$_GIT_GUEST" ]]; then
	echo "# Building git-guest..."
	bash "$_PROJ_ROOT/libgit2/build_component.sh" >/dev/null 2>&1
fi

# Build python guest if missing
if [[ ! -f "$_PY_GUEST" ]]; then
	echo "# Building python-guest..."
	bash "$_PROJ_ROOT/micropython-1.27.0-wasi/ports/wasi/build_component.sh" >/dev/null 2>&1
fi

# Compose if missing or stale
if [[ ! -f "$_COMPOSED" ]] || \
   [[ "$_HOST_COMP" -nt "$_COMPOSED" ]] || \
   [[ "$_GIT_GUEST" -nt "$_COMPOSED" ]] || \
   [[ "$_PY_GUEST" -nt "$_COMPOSED" ]]; then
	echo "# Composing components..."
	if ! command -v wac &>/dev/null; then
		for i in $(seq 1 20); do skip "wac not found"; done
		done_testing
		exit 0
	fi
	wac plug "$_HOST_COMP" \
		--plug "$_GIT_GUEST" \
		--plug "$_PY_GUEST" \
		-o "$_COMPOSED" 2>/dev/null
fi

if [[ ! -f "$_COMPOSED" ]]; then
	for i in $(seq 1 20); do skip "composed binary not available"; done
	done_testing
	exit 0
fi

# ========================= Basic sanity =========================

co_run echo "hello"
is "$_CO_STDOUT" "hello" "component: echo still works"

co_run_wsh 'echo hello'
is "$_CO_STDOUT" "hello" "component: wsh echo works"

# ========================= git sub-command =========================

# git --version (libgit2 CLI outputs "git2 version")
co_run_wsh 'git --version'
like "$_CO_STDOUT" "git.*version" "component: git --version"

# git init with explicit path under /tmp
co_run_wsh 'git init /tmp/gitrepo'
cmp_ok "$_CO_EXIT" "==" "0" "component: git init succeeds"
like "$_CO_STDOUT" "Initialized" "component: git init output"

# git via pipe
co_run_wsh 'git --version | cat'
like "$_CO_STDOUT" "git.*version" "component: git through pipe"

# git help
co_run_wsh 'git help'
cmp_ok "$_CO_EXIT" "==" "0" "component: git help succeeds"

# ========================= python sub-command =========================

# python -c basic print
co_run_wsh 'python -c "print(42)"'
is "$_CO_STDOUT" "42" "component: python print integer"

# python -c print string
co_run_wsh 'python -c "print(\"hello python\")"'
is "$_CO_STDOUT" "hello python" "component: python print string"

# python -c arithmetic
co_run_wsh 'python -c "print(1+1)"'
is "$_CO_STDOUT" "2" "component: python -c arithmetic"

# python -c multi-statement
co_run_wsh 'python -c "x=10; print(x*2)"'
is "$_CO_STDOUT" "20" "component: python multi-statement"

# python3 alias
co_run_wsh 'python3 -c "print(\"alias works\")"'
is "$_CO_STDOUT" "alias works" "component: python3 alias works"

# python via pipe
co_run_wsh 'python -c "print(100)" | cat'
is "$_CO_STDOUT" "100" "component: python through pipe"

# python -c with complex expression
co_run_wsh 'python -c "import sys; print(sys.version_info[0])"'
like "$_CO_STDOUT" "3" "component: python sys.version_info"

# ========================= git + python combined =========================

# Both git and python in sequence
co_run_wsh 'git --version; python -c "print(\"done\")"'
like "$_CO_STDOUT" "git.*version" "component: git and python in sequence (git)"
like "$_CO_STDOUT" "done" "component: git and python in sequence (python)"

# python generates file, git init in same dir
co_run_wsh 'python -c "print(\"generated\")" > /tmp/gitrepo/gen.txt; git add /tmp/gitrepo/gen.txt'
cmp_ok "$_CO_EXIT" "==" "0" "component: python output to git add"

done_testing

# Cleanup
rm -rf /tmp/gitrepo
