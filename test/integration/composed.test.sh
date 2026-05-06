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

_COMPOSED="$_PROJ_ROOT/busybox-wasi/busybox.wasm"
_GIT_GUEST="$_PROJ_ROOT/libgit2/build-component/git-guest.wasm"
_PY_GUEST="$_PROJ_ROOT/micropython-1.27.0-wasi/ports/wasi/build-component/micropython-guest.wasm"
_HOST_COMP="$_PROJ_ROOT/busybox-wasi/build/busybox-host.wasm"

# Helper: run command through composed binary via wsh
# Sets: _CO_EXIT, _CO_STDOUT
co_run_wsh() {
	local cmd="$1"
	local tmperr="$_TEST_TMPDIR/_co_stderr.txt"

	_CO_STDOUT=$($_WASMTIME $_WASM_FLAGS --dir="$_WASM_DIR" --dir=/tmp \
		"$_COMPOSED" wsh -c "$cmd" 2>"$tmperr") && _CO_EXIT=0 || _CO_EXIT=$?
	local stderr_out
	stderr_out="$(cat "$tmperr" 2>/dev/null)" || stderr_out=""
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
		"$_COMPOSED" "$@" 2>"$stderr_dest") && _CO_EXIT=0 || _CO_EXIT=$?
}

# ========================= Build & compose =========================

plan 28

setup

# --- Check prerequisites ---

if [[ ! -x "$_WASMTIME" ]]; then
	skip "wasmtime not found at $_WASMTIME"
	skip "wasmtime not found"
	# ... skip all
	for i in $(seq 1 26); do skip "wasmtime not found"; done
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
		skip "wac not found, cannot compose"
		for i in $(seq 1 27); do skip "wac not found"; done
		done_testing
		exit 0
	fi
	wac plug "$_HOST_COMP" \
		--plug "$_GIT_GUEST" \
		--plug "$_PY_GUEST" \
		-o "$_COMPOSED" 2>/dev/null
fi

if [[ ! -f "$_COMPOSED" ]]; then
	for i in $(seq 1 28); do skip "composed binary not available"; done
	done_testing
	exit 0
fi

# ========================= Basic sanity =========================

# Composed binary still runs normal busybox applets
co_run echo "hello"
is "$_CO_STDOUT" "hello" "component: echo still works"

co_run wsh -c 'echo hello'
is "$_CO_STDOUT" "hello" "component: wsh echo works"

# ========================= git sub-command =========================

# git --version
co_run_wsh 'git --version'
like "$_CO_STDOUT" "git version" "component: git --version"

# git init
cd "$_WASM_DIR"
co_run_wsh 'git init'
cmp_ok "$_CO_EXIT" "==" "0" "component: git init succeeds"
like "$_CO_STDOUT" "Initialized\|init" "component: git init output"

# git status (empty repo)
co_run_wsh 'git status'
cmp_ok "$_CO_EXIT" "==" "0" "component: git status succeeds"

# git add + status
mkfile "$_WASM_DIR/test.txt" "hello git"
co_run_wsh 'git add test.txt'
cmp_ok "$_CO_EXIT" "==" "0" "component: git add succeeds"

co_run_wsh 'git status'
like "$_CO_STDOUT" "test.txt" "component: git status shows tracked file"

# git log (no commits yet = error)
co_run_wsh 'git log'
cmp_ok "$_CO_EXIT" "!=" "0" "component: git log with no commits returns error"

# git branch
co_run_wsh 'git branch'
cmp_ok "$_CO_EXIT" "==" "0" "component: git branch succeeds"

# git via pipe
co_run_wsh 'git --version | cat'
like "$_CO_STDOUT" "git version" "component: git through pipe"

# git with quoted args
co_run_wsh 'echo "test content" > commit.txt; git add commit.txt'
cmp_ok "$_CO_EXIT" "==" "0" "component: git add with quoted content"

# ========================= python sub-command =========================

# python basic print
co_run_wsh 'python "print(42)"'
is "$_CO_STDOUT" "42" "component: python print integer"

# python print string
co_run_wsh 'python "print(\"hello python\")"'
is "$_CO_STDOUT" "hello python" "component: python print string"

# python -c flag
co_run_wsh 'python -c "print(1+1)"'
is "$_CO_STDOUT" "2" "component: python -c arithmetic"

# python multi-line via semicolons in quotes
co_run_wsh 'python "x=10; print(x*2)"'
is "$_CO_STDOUT" "20" "component: python multi-statement"

# python3 alias
co_run_wsh 'python3 "print(\"alias works\")"'
is "$_CO_STDOUT" "alias works" "component: python3 alias works"

# python via pipe
co_run_wsh 'python "print(100)" | cat'
is "$_CO_STDOUT" "100" "component: python through pipe"

# python with quoted arg containing spaces (core quoting fix)
co_run_wsh 'python "import sys; print(len(sys.argv))"'
like "$_CO_STDOUT" "1" "component: python quoted arg not split"

# python -c with complex expression
co_run_wsh 'python -c "import sys; print(sys.version_info[0])"'
like "$_CO_STDOUT" "3" "component: python sys.version_info"

# ========================= git + python combined =========================

# Use python to generate content, git to track it
co_run_wsh 'python "print(\"generated\")" > gen.txt; git add gen.txt'
cmp_ok "$_CO_EXIT" "==" "0" "component: python output piped to git add"

co_run_wsh 'git status'
like "$_CO_STDOUT" "gen.txt" "component: git sees python-generated file"

# Both git and python in pipeline
co_run_wsh 'git --version; python "print(\"done\")"'
like "$_CO_STDOUT" "git version" "component: git and python in sequence (git)"
like "$_CO_STDOUT" "done" "component: git and python in sequence (python)"

done_testing
