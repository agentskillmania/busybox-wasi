# WSH — WebAssembly Shell

> 为单进程 WASM 环境设计的最小化 shell。[BusyBox WASM](README_zh.md) 的一部分。
> [English Documentation](WSH.md)

## 简介

WSH（WebAssembly Shell）是专门为 BusyBox WASM 移植版构建的自定义 shell。传统 shell（bash、ash、zsh）依赖 `fork()`、`pipe()`、`dup()` 实现进程管理和管道，而 WSH 完全在单个 WASM 进程中运行，通过临时文件模拟管道。

## 快速开始

```bash
# 基本执行
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'echo hello world'

# 变量和管道
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'X=world; echo hello $X | tr a-z A-Z'

# 文件操作（需要 --dir 授权文件系统访问）
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'echo content > /tmp/file.txt; cat /tmp/file.txt'
```

## 语法参考

### 变量

```bash
X=hello                        # 赋值（等号两侧不能有空格）
echo $X                        # → hello
echo ${X}                      # → hello（花括号展开）
echo ${X}_suffix               # → hello_suffix（拼接）
echo $(echo dynamic)           # → dynamic（命令替换）
echo $(echo $(echo nested))    # → nested（嵌套命令替换）
```

### 特殊变量

| 变量 | 含义 |
|------|------|
| `$?` | 上一条命令的退出码 |
| `$$` | 伪 PID（WASM 中返回固定数字） |

### 控制流

**if/elif/else/fi** — 完整的条件判断，支持嵌套：

```bash
if test $X -eq 1; then echo one
elif test $X -eq 2; then echo two
else echo other
fi
```

**for/in/do/done** — 遍历词列表：

```bash
for i in a b c; do echo $i; done
# 嵌套循环：
for i in a b; do for j in 1 2; do echo $i$j; done; done
```

**while/do/done** — 条件循环：

```bash
X=0
while [ $X -lt 3 ]; do
    echo $X
    X=$(expr $X + 1)
done
```

### 管道

管道使用临时文件在阶段间传递数据。所有阶段串行执行（非并行）：

```bash
echo hello | tr a-z A-Z              # → HELLO
seq 1 5 | sort -r | head -1          # → 5
echo banana | sort | head -1         # → banana
```

**多行数据管道**：对多行数据，先写入文件再从文件管道读取。wsh 管道上下文中 `echo -e` 不会产生换行：

```bash
# 先写入文件，再从文件读取
printf 'aaa\nbbb\nccc\n' > /tmp/data.txt
grep aaa /tmp/data.txt | wc -l       # → 1
```

### I/O 重定向

| 操作符 | 含义 |
|--------|------|
| `> file` | stdout 重定向到文件（覆盖） |
| `>> file` | stdout 重定向到文件（追加） |
| `< file` | stdin 从文件读取 |
| `2> file` | stderr 重定向到文件 |

```bash
echo hello > /tmp/out.txt        # 写入文件
echo world >> /tmp/out.txt       # 追加
cat < /tmp/out.txt               # 从文件读取
```

### 子 Shell

`( ... )` 创建变量作用域。内部修改不影响外部：

```bash
X=outer; (X=inner; echo $X); echo $X
# → inner
# → outer
```

### Glob 模式

```bash
ls /tmp/*.txt          # 展开通配符匹配文件
```

支持 `*`（任意字符串）和 `?`（单个字符）。

### 命令分隔符

```bash
echo one; echo two    # 顺序执行
```

### 错误处理

```bash
nonexistent_command    # 打印错误，返回非零退出码
echo $?                # → 127（命令未找到）
```

## 工作原理

### 管道实现

WASI 没有 `fork()` 或 `pipe()`，WSH 通过临时文件实现管道：

```
echo hello | tr a-z A-Z | cat

第 1 步：echo hello    → 写 stdout 到 /tmp/_wsh_p_0
第 2 步：tr a-z A-Z   ← 从 /tmp/_wsh_p_0 读 stdin
                         → 写 stdout 到 /tmp/_wsh_p_1
第 3 步：cat           ← 从 /tmp/_wsh_p_1 读 stdin
                         → 结果输出到 stderr（终端）
```

管道的最后阶段输出到 **stderr**（而非 stdout），因为 `freopen()` 将 stdout 重定向到了临时文件，且无法恢复。stderr 始终指向终端。

### 命令替换

`$(cmd)` 捕获命令输出的流程：
1. 将 stdout 重定向到临时文件
2. 执行命令
3. 读取文件并去除尾部换行符

支持嵌套：`$(echo $(echo deep))` 通过递归展开实现。

## 支持的功能

| 功能 | 状态 | 说明 |
|------|------|------|
| 变量赋值/展开 | 支持 | `$VAR`、`${VAR}` |
| 命令替换 | 支持 | `$(cmd)`、嵌套 `$(echo $(...))` |
| 管道 | 支持 | 通过临时文件，串行执行 |
| I/O 重定向 | 支持 | `>`、`>>`、`<`、`2>` |
| if/elif/else/fi | 支持 | 可嵌套 |
| for/in/do/done | 支持 | 可嵌套 |
| while/do/done | 支持 | 可用 `expr` 或 `$((...))` 做算术 |
| case/in/esac | 支持 | 可嵌套，分支支持 glob 模式 |
| 子 Shell | 支持 | 通过 save/restore 实现变量作用域 |
| Glob 模式 | 支持 | 文件路径中的 `*`、`?` |
| `&&` / `||` 操作符 | 支持 | 真正的短路逻辑 |
| 换行作为命令分隔 | 支持 | 隐式 `;` |
| `#` 注释 | 支持 | 到行尾 |
| `$((...))` 算术 | 支持 | `+ - * / %`、括号、变量 |
| `$?` 退出码 | 支持 | |
| `$$` 伪 PID | 支持 | 返回固定数字 |
| `;` 命令分隔 | 支持 | |

## 已知限制

### 不支持

| 功能 | 原因 |
|------|------|
| `break` / `continue` | 未实现 |
| `$#`、`$0`-`$9` | 位置参数不可用 |
| `$!` | 后台进程 PID 不适用 |
| 函数定义 | 设计取舍——智能体脚本不需要 |
| 单引号剥离 | 单引号原样传递（双引号会剥离） |
| `echo -e` 在管道中 | `\n` 在 wsh 管道数据中不会展开 |
| 交互模式 | 仅支持 `-c CMD` 模式 |

### 行为说明

- **引号处理**：`echo 'hello'` 输出 `'hello'`（带引号）。单引号在变量展开时未剥离。双引号*会*剥离。变通方案是尽量避免使用单引号：
  ```bash
  echo hello world          # 正常工作（简单词不需要引号）
  echo $VAR                 # 变量展开无需引号
  echo "hello $VAR"         # 双引号会剥离，变量正常展开
  ```
- **多行管道数据**：包含换行的数据，先写入文件，再从文件管道读取。
- **管道输出到 stderr**：管道最后阶段写入 stderr。正常使用时不可见，但重定向 stderr 时可能需要注意。

## 架构

```
源文件：
  shell/wsh.c        — 入口（参数解析）
  shell/wsh_parse.c  — 递归下降解析器 + 分词器
  shell/wsh_vars.c   — 变量存储、展开、命令替换
  shell/wsh_pipe.c   — 管道执行、glob、I/O 重定向、applet 调度
  shell/wsh_parse.h  — 解析器公共 API
  shell/wsh_vars.h   — 变量 API
  shell/wsh_pipe.h   — 管道 API
```

### 分词 → 解析 → 执行流程

```
输入：'X=hello; echo $X | tr a-z A-Z'
  │
  ▼ wsh_tokenize()
Token：[X=hello] [;] [echo] [$X] [|] [tr] [a-z] [A-Z]
  │
  ▼ wsh_parse_list()
  ├── wsh_exec_segment("X=hello")
  │     └── wsh_try_assign() → 设置 X=hello
  │
  └── wsh_exec_segment("echo $X | tr a-z A-Z")
        └── wsh_run_pipeline()
              ├── 展开："echo hello | tr a-z A-Z"
              ├── 按 | 分割：["echo hello", "tr a-z A-Z"]
              ├── 阶段 0：echo hello → /tmp/_wsh_p_0
              └── 阶段 1：tr a-z A-Z ← /tmp/_wsh_p_0 → stderr
```
