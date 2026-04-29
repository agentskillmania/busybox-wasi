# WSH — WebAssembly Shell

> A minimal shell designed for single-process WASM environments. Part of [BusyBox WASM](README.md).
> [中文文档](WSH_zh.md)

## Overview

WSH (WebAssembly Shell) is a custom shell built specifically for the BusyBox WASM port. Unlike traditional shells (bash, ash, zsh) that rely on `fork()`, `pipe()`, and `dup()` for process management and pipelines, WSH operates entirely within a single WASM process. It simulates pipelines using temporary files instead of OS-level pipes.

## Quick Start

```bash
# Basic execution
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'echo hello world'

# With variables and pipes
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'X=world; echo hello $X | tr a-z A-Z'

# File operations (grant --dir for filesystem access)
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'echo content > /tmp/file.txt; cat /tmp/file.txt'
```

## Syntax Reference

### Variables

```bash
X=hello                        # Assignment (no spaces around =)
echo $X                        # → hello
echo ${X}                      # → hello (brace expansion)
echo ${X}_suffix               # → hello_suffix (concatenation)
echo $(echo dynamic)           # → dynamic (command substitution)
echo $(echo $(echo nested))    # → nested (nested substitution)
```

### Special Variables

| Variable | Meaning |
|----------|---------|
| `$?` | Exit code of the last command |
| `$$` | Pseudo PID (always returns a fixed number in WASM) |

### Control Flow

**if/elif/else/fi** — Full conditional with nesting:

```bash
if test $X -eq 1; then echo one
elif test $X -eq 2; then echo two
else echo other
fi
```

**for/in/do/done** — Iterate over word lists:

```bash
for i in a b c; do echo $i; done
# Nested loops:
for i in a b; do for j in 1 2; do echo $i$j; done; done
```

**while/do/done** — Loop with condition:

```bash
X=0
while [ $X -lt 3 ]; do
    echo $X
    X=$(expr $X + 1)
done
```

### Pipelines

Pipelines use temporary files to pass data between stages. All stages run sequentially (not in parallel):

```bash
echo hello | tr a-z A-Z              # → HELLO
seq 1 5 | sort -r | head -1          # → 5
echo banana | sort | head -1         # → banana
```

**Multi-line data in pipes**: Use files for multi-line data. `echo -e` inside wsh does not produce newlines in pipe contexts:

```bash
# Write multi-line data to file first, then pipe from file
printf 'aaa\nbbb\nccc\n' > /tmp/data.txt
grep aaa /tmp/data.txt | wc -l       # → 1
```

### I/O Redirection

| Operator | Meaning |
|----------|---------|
| `> file` | Redirect stdout to file (overwrite) |
| `>> file` | Redirect stdout to file (append) |
| `< file` | Redirect stdin from file |
| `2> file` | Redirect stderr to file |

```bash
echo hello > /tmp/out.txt        # Write to file
echo world >> /tmp/out.txt       # Append
cat < /tmp/out.txt               # Read from file
```

### Subshells

`( ... )` creates a variable scope. Changes inside do not affect the parent:

```bash
X=outer; (X=inner; echo $X); echo $X
# → inner
# → outer
```

### Glob Patterns

```bash
ls /tmp/*.txt          # Expands *.txt to matching files
```

Supports `*` (any string) and `?` (single character).

### Command Separators

```bash
echo one; echo two    # Sequential execution
```

### Error Handling

```bash
nonexistent_command    # Prints error, returns non-zero exit code
echo $?                # → 127 (command not found)
```

## How It Works

### Pipeline Implementation

Since WASI has no `fork()` or `pipe()`, WSH implements pipelines via temporary files:

```
echo hello | tr a-z A-Z | cat

Step 1: echo hello    → write stdout to /tmp/_wsh_p_0
Step 2: tr a-z A-Z   ← read stdin from /tmp/_wsh_p_0
                         → write stdout to /tmp/_wsh_p_1
Step 3: cat           ← read stdin from /tmp/_wsh_p_1
                         → write result to stderr (terminal)
```

The final pipeline stage outputs to **stderr** (not stdout), because `freopen()` is used to redirect stdout to temporary files and there is no way to restore it. Stderr always points to the terminal.

### Command Substitution

`$(cmd)` captures a command's output by:
1. Redirecting stdout to a temporary file
2. Executing the command
3. Reading the file and stripping trailing newlines

Nesting is supported: `$(echo $(echo deep))` works by recursive expansion.

## Supported Features

| Feature | Status | Notes |
|---------|--------|-------|
| Variable assignment/expansion | Supported | `$VAR`, `${VAR}` |
| Command substitution | Supported | `$(cmd)`, nested `$(echo $(...))` |
| Pipelines | Supported | Via temp files, sequential |
| I/O redirection | Supported | `>`, `>>`, `<`, `2>` |
| if/elif/else/fi | Supported | Nestable |
| for/in/do/done | Supported | Nestable |
| while/do/done | Supported | With `expr` or `$((...))` for arithmetic |
| case/in/esac | Supported | Nestable, glob patterns in branches |
| Subshells | Supported | Variable scoping via save/restore |
| Glob patterns | Supported | `*`, `?` in file paths |
| `&&` / `||` operators | Supported | Real short-circuit logic |
| Newline as command separator | Supported | Implicit `;` between commands |
| `#` comments | Supported | To end of line |
| `$((...))` arithmetic | Supported | `+ - * / %`, parentheses, variables |
| `$?` exit code | Supported | |
| `$$` pseudo PID | Supported | Returns fixed number |
| `;` command separator | Supported | |

## Known Limitations

### Not Supported

| Feature | Reason |
|---------|--------|
| `break` / `continue` | Not implemented |
| `$#`, `$0`-`$9` | Positional parameters not available |
| `$!` | Background process PID not applicable |
| Function definitions | Design choice — not needed for agent scripts |
| Single-quote stripping | Single quotes passed through literally (double quotes are stripped) |
| `echo -e` in pipes | `\n` not expanded inside wsh pipe data |
| Interactive mode | Only `-c CMD` mode supported |

### Behavioral Notes

- **Quote handling**: `echo 'hello'` outputs `'hello'` (with quotes). Single quotes are not stripped during variable expansion. Double quotes *are* stripped. As a workaround, avoid single quotes when possible:
  ```bash
  echo hello world          # Works fine (no quotes needed for simple words)
  echo $VAR                 # Variables expand without quotes
  echo "hello $VAR"         # Double quotes are stripped, variables expand
  ```
- **Multi-line pipe data**: For data containing newlines, write to a file first, then pipe from the file.
- **Pipeline output goes to stderr**: The final stage of a pipeline writes to stderr. This is invisible for normal usage but may matter if you redirect stderr.

## Architecture

```
Source files:
  shell/wsh.c        — Entry point (argument parsing)
  shell/wsh_parse.c  — Recursive descent parser + tokenizer
  shell/wsh_vars.c   — Variable storage, expansion, command substitution
  shell/wsh_pipe.c   — Pipeline execution, glob, I/O redirection, applet dispatch
  shell/wsh_parse.h  — Parser public API
  shell/wsh_vars.h   — Variable API
  shell/wsh_pipe.h   — Pipeline API
```

### Tokenizer → Parser → Execution Flow

```
Input: 'X=hello; echo $X | tr a-z A-Z'
  │
  ▼ wsh_tokenize()
Tokens: [X=hello] [;] [echo] [$X] [|] [tr] [a-z] [A-Z]
  │
  ▼ wsh_parse_list()
  ├── wsh_exec_segment("X=hello")
  │     └── wsh_try_assign() → sets X=hello
  │
  └── wsh_exec_segment("echo $X | tr a-z A-Z")
        └── wsh_run_pipeline()
              ├── expand: "echo hello | tr a-z A-Z"
              ├── split by |: ["echo hello", "tr a-z A-Z"]
              ├── stage 0: echo hello → /tmp/_wsh_p_0
              └── stage 1: tr a-z A-Z ← /tmp/_wsh_p_0 → stderr
```
