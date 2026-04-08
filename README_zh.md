# BusyBox WASM

> 基于 [WASI SDK](https://github.com/WebAssembly/wasi-sdk) 将 BusyBox 1.37.0 编译为 WebAssembly，可在 [wasmtime](https://wasmtime.dev/) 等 WASI 运行时中执行。

[English Documentation](README.md)

## 项目简介

本项目将 [BusyBox](https://busybox.net/) —— 嵌入式 Linux 的瑞士军刀 —— 移植到 WebAssembly 平台。产出单个 `busybox.wasm` 二进制文件，包含 **134 个标准 Unix 工具**，可在任何兼容 WASI 的运行时中运行。

这不是 BusyBox 官方项目。它是在 BusyBox 1.37.0 源码基础上添加 WASI 兼容层的分支版本。

## 快速开始

### 依赖

| 依赖 | 要求版本 | 说明 |
|------|---------|------|
| [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) | **22**（clang 22.1.0） | 必须提供 `wasm32-wasip2` 目标。更新版本不保证兼容。 |
| [wasmtime](https://wasmtime.dev/) | **43.0.0** | 需要 `-W exceptions=y` 支持 setjmp/longjmp。更新版本不保证兼容。 |
| GNU Make | 任意版本 | 构建系统 |
| 标准 Unix 工具 | 任意版本 | `bash`、`sed`、`awk` 等 |

> **注意**：本项目使用 WASI Preview 2（wasip2）和 WASM Exception Handling 提案。上方版本为测试通过的版本，其他版本或运行时不保证可用。

### 构建

**方式一：一键脚本**（配置、编译、验证全流程）

```bash
./build_wasm.sh
```

脚本会读取 `configs/wasm_defconfig` 生成配置，执行 `make clean`、编译、拷贝 `busybox.wasm`，并运行验证测试。可通过 `WASI_SDK` 和 `WASMTIME` 环境变量覆盖默认路径。

**方式二：手动构建**

```bash
make clean
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk SKIP_STRIP=y -j$(nproc)
cp busybox_unstripped busybox.wasm
```

### 运行

```bash
# 执行任意内置命令
wasmtime -W exceptions=y busybox.wasm echo "Hello, WebAssembly!"

# 列出所有可用命令
wasmtime -W exceptions=y busybox.wasm --list

# 文件操作（需要 --dir 参数授权文件系统访问）
wasmtime -W exceptions=y --dir=/tmp busybox.wasm ls /tmp

# 使用内置 shell（wsh）
wasmtime -W exceptions=y --dir=/tmp busybox.wasm wsh -c 'echo hello | tr a-z A-Z'
```

## 支持的命令（134 个）

### 归档工具

| 命令 | 说明 |
|------|------|
| `bunzip2` | 解压 bzip2 文件 |
| `bzcat` | 解压 bzip2 到 stdout |
| `bzip2` | bzip2 压缩 |
| `cpio` | 归档拷贝 |
| `dpkg` | Debian 包管理器 |
| `dpkg-deb` | Debian 包归档工具 |
| `gunzip` | 解压 gzip 文件 |
| `gzip` | gzip 压缩 |
| `lzcat` | 解压 lzma 到 stdout |
| `lzma` | lzma 压缩 |
| `lzop` | lzop 压缩 |
| `rpm` | RPM 包管理器 |
| `rpm2cpio` | RPM 转 cpio |
| `tar` | 磁带归档工具 |
| `unlzma` | 解压 lzma 文件 |
| `unxz` | 解压 xz 文件 |
| `unzip` | 解压 zip 归档 |
| `xz` | xz 压缩 |
| `xzcat` | 解压 xz 到 stdout |
| `zcat` | 解压 gzip 到 stdout |

### 核心工具（Coreutils）

| 命令 | 说明 |
|------|------|
| `arch` | 打印机器架构 |
| `base32` | Base32 编解码 |
| `base64` | Base64 编解码 |
| `basename` | 去除目录和后缀 |
| `cat` | 连接文件 |
| `chroot` | 切换根目录 |
| `chmod` | 修改文件权限 |
| `cksum` | CRC 和字节计数 |
| `comm` | 比较已排序文件 |
| `cp` | 复制文件 |
| `crc32` | CRC32 校验 |
| `cut` | 去除行中指定部分 |
| `date` | 打印/设置日期 |
| `dd` | 转换并复制文件 |
| `dirname` | 去除文件名 |
| `dos2unix` | DOS 换行转 Unix |
| `unix2dos` | Unix 换行转 DOS |
| `du` | 磁盘用量 |
| `echo` | 输出文本 |
| `env` | 设置环境变量 |
| `expand` | Tab 转空格 |
| `unexpand` | 空格转 Tab |
| `expr` | 求值表达式 |
| `factor` | 因数分解 |
| `false` | 返回 false |
| `fold` | 折行 |
| `groups` | 打印组归属 |
| `head` | 输出前 N 行 |
| `install` | 复制文件并设置属性 |
| `link` | 创建硬链接 |
| `ln` | 创建链接 |
| `ls` | 列出目录内容 |
| `md5sum` | MD5 校验 |
| `sha1sum` | SHA1 校验 |
| `sha256sum` | SHA256 校验 |
| `sha3sum` | SHA3 校验 |
| `sha512sum` | SHA512 校验 |
| `mkdir` | 创建目录 |
| `mktemp` | 创建临时文件 |
| `mv` | 移动/重命名文件 |
| `nice` | 设置进程优先级 |
| `nl` | 标行号 |
| `nohup` | 免挂断运行 |
| `od` | 八进制转储 |
| `paste` | 合并文件行 |
| `printenv` | 打印环境变量 |
| `printf` | 格式化输出 |
| `pwd` | 打印工作目录 |
| `realpath` | 打印解析后路径 |
| `rm` | 删除文件 |
| `rmdir` | 删除目录 |
| `seq` | 输出数字序列 |
| `shred` | 安全覆写文件 |
| `shuf` | 随机打乱行 |
| `sleep` | 延时 |
| `sort` | 排序 |
| `split` | 分割文件 |
| `stat` | 文件状态 |
| `sum` | 校验和与块计数 |
| `sync` | 刷新文件系统缓存 |
| `fsync` | 同步文件到磁盘 |
| `tac` | 逆序连接 |
| `tail` | 输出末尾行 |
| `tee` | 从 stdin 读，写 stdout 和文件 |
| `test` | 文件类型和值测试 |
| `touch` | 修改文件时间戳 |
| `tr` | 字符转换 |
| `true` | 返回 true |
| `truncate` | 缩减/扩展文件 |
| `tsort` | 拓扑排序 |
| `uname` | 打印系统信息 |
| `uniq` | 去重行 |
| `unlink` | 删除单个文件 |
| `usleep` | 微秒延时 |
| `uudecode` | 解码 uuencode 数据 |
| `uuencode` | 编码二进制数据 |
| `wc` | 统计字/行/字节 |
| `yes` | 重复输出字符串 |

### 编辑器

| 命令 | 说明 |
|------|------|
| `awk` | 模式扫描语言 |
| `cmp` | 逐字节比较文件 |
| `diff` | 逐行比较文件 |
| `ed` | 行编辑器 |
| `patch` | 应用差异 |
| `sed` | 流编辑器 |
| `vi` | 屏幕编辑器 |

### 查找工具

| 命令 | 说明 |
|------|------|
| `egrep` | 扩展正则搜索 |
| `fgrep` | 固定字符串搜索 |
| `grep` | 文本模式搜索 |

### 网络工具

| 命令 | 说明 |
|------|------|
| `ftpget` | FTP 下载 |
| `ftpput` | FTP 上传 |
| `nc` / `netcat` | TCP/UDP 网络工具 |
| `nslookup` | DNS 查询 |
| `tcpsvd` | TCP 服务守护进程 |
| `telnet` | Telnet 客户端 |
| `udpsvd` | UDP 服务守护进程 |
| `wget` | HTTP/HTTPS 下载 |
| `whois` | WHOIS 客户端 |

### 系统工具

| 命令 | 说明 |
|------|------|
| `cal` | 显示日历 |
| `dmesg` | 打印内核消息 |
| `getopt` | 解析命令选项 |
| `hd` | 十六进制转储（同 hexdump -C） |
| `hexdump` | 十六进制转储 |
| `rev` | 反转行 |
| `xxd` | 十六进制转储 |

### 杂项工具

| 命令 | 说明 |
|------|------|
| `ascii` | 打印 ASCII 表 |
| `bc` | 任意精度计算器 |
| `dc` | 桌面计算器 |
| `pipe_progress` | 显示管道进度 |
| `run-parts` | 执行目录中的脚本 |
| `strings` | 打印可打印字符串 |
| `wsh` | WASM shell（自定义） |

### Shell

| 命令 | 说明 |
|------|------|
| `wsh` | WASM 环境轻量 shell |

## 架构

```
                          用户
                           |
                    wasmtime 运行时
                           |
                  +--------+--------+
                  |  busybox.wasm   |
                  +--------+--------+
                           |
              +------------+------------+
              |                         |
     wasi_main.c              WASI 兼容层
     （入口桥接）              （stub + 头文件补丁）
              |                         |
              +------------+------------+
                           |
                  BusyBox applet 调度
                           |
         +---------+-------+-------+---------+
         |         |               |         |
      coreutils  archival    networking   editors ...
```

### WASI 适配层

| 文件 | 作用 |
|------|------|
| `wasi_main.c` | 入口桥接：`__main_argc_argv` -> `busybox_real_main` |
| `wasi/wasi_stubs.c` | POSIX 函数 stub（fork、pipe、signal 等），返回 `ENOSYS` 或安全默认值 |
| `wasi/wasi_compat.h` | 函数声明补丁，修复 WASI 头文件缺失的声明 |
| `wasi_include/` | 补充 WASI 缺失的 POSIX 定义的头文件目录 |
| `arch/wasm32/Makefile` | WASM 工具链配置 |
| `wasm-ld-wrapper.sh` | 过滤 `-nostdlib`，兼容 wasm-ld |

## 手动构建

如果不使用 `build_wasm.sh` 脚本：

```bash
make clean
make ARCH=wasm32 WASI_SDK=/path/to/wasi-sdk SKIP_STRIP=y -j$(nproc)
cp busybox_unstripped busybox.wasm
```

修改构建配置可编辑 `configs/wasm_defconfig`，或运行：

```bash
make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk menuconfig
```

## 限制

这是在沙箱环境中运行的 WebAssembly 移植版本，许多 POSIX 功能通过 stub 模拟：

| 类别 | 状态 | 说明 |
|------|------|------|
| 文件 I/O | 部分可用 | 需要运行时 `--dir=` 参数授权文件系统访问 |
| 网络 | 部分可用 | HTTP（wget）、DNS（nslookup）、TCP（nc/telnet）在部分运行时可用 |
| 进程管理 | 不可用 | 无 `fork()`、`exec()`、`waitpid()`，始终返回错误 |
| 管道 | 不可用 | 无 `pipe()`、`dup2()`，shell 管道不可用 |
| 信号 | 不可用 | stub 返回 `ENOSYS`，无 `kill`、`SIGINT` 处理 |
| 用户/组 | 不可用 | `getpwuid()`、`getgrnam()` 返回 NULL |
| 挂载/文件系统 | 不可用 | 无 `mount()`、`umount()`，`statfs()` 返回默认值 |
| 终端 | 有限 | `tcgetattr()`/`tcsetattr()` 返回 -1，`vi` 可在基本模式下使用 |
| 符号链接 | 不可用 | wasmtime 禁止创建符号链接，`ln -s` 返回 EPERM |
| 文件权限 | 忽略 | `chmod`、`fchmod`、`chown` 在 WASM 沙箱中为空操作 |

**能正常工作的命令**：文件操作（cat、cp、mv、rm、ls）、文本处理（grep、sed、awk、sort）、压缩（gzip、bzip2、xz）、校验和（md5sum、sha256sum）等单进程工具。

**不能工作的命令**：需要进程管理的命令（ps、top、kill）、挂载操作（mount、umount）、用户管理（useradd、passwd）或进程间管道的命令。

### 已从构建中移除的命令

以下命令因依赖 WASI 不兼容的 API（无法绕开）已从构建中移除：

| 命令 | 移除原因 |
|------|---------|
| `df` | 依赖 `/proc/mounts` 和 `statfs()` — WASI 无文件系统统计接口 |
| `mkfifo` | 依赖 `mknod()` — WASI 无设备节点或命名管道概念 |
| `readlink` | 依赖符号链接 — wasmtime 禁止创建符号链接 |
| `timeout` | 依赖 `vfork()` — WASM 单进程模型 |
| `tty` | WASI 无终端设备概念 |
| `which` | WASM 沙箱中无可访问的 PATH 目录 |

### 有已知限制的命令

以下命令已包含在构建中，但功能部分受限：

| 命令 | 限制 |
|------|------|
| `chmod` | 空操作（WASM 沙箱无权限模型） |
| `env` | WASM 无环境变量；`env COMMAND` 因无法 exec 而失败 |
| `gunzip` / `bunzip2` / `unlzma` / `unxz` | 文件解压可用；`zcat` 的 SEAMLESS_MAGIC 模式不可用（需 fork+pipe） |
| `gzip` / `bzip2` / `xz` | 文件压缩可用 |
| `ln` | 仅支持硬链接；`ln -s` 返回 EPERM（符号链接被禁用） |
| `nohup` | 信号相关操作为空 stub；命令仍正常执行 |
| `nice` | 空操作 stub；在 WASM 中进程优先级无意义 |
| `nslookup` | DNS stub 不完整；部分查询类型可能失败 |
| `tar` | 非压缩模式可用；压缩模式（tar -z 等）需 fork+pipe |
| `unzip -t` | 测试模式打开 `/dev/null`，WASI 中不存在；请使用 `unzip -l` 替代 |

## 许可证

BusyBox 采用 **GNU General Public License v2** 许可。详见 [LICENSE](LICENSE)。

WASM 适配层文件同样采用 GPL v2，因为它们派生自 BusyBox 源码。
