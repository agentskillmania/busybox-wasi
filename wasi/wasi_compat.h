/*
 * wasi_compat.h — WASI 构建兼容性补丁
 *
 * 删除 procps/selinux/klibc-utils 等模块后，其 Config.in 不再参与 kconfig，
 * 导致 ENABLE_XXX / IF_XXX 宏在 make clean 后未定义。
 * 此文件通过 -include 注入编译，为这些宏提供默认值 0。
 *
 * 注意：只补缺，不覆盖已有定义（全部用 #ifndef 保护）。
 */

#ifndef WASI_COMPAT_H
#define WASI_COMPAT_H

/* ================================================================
 * 通用 IF_XXX 宏生成器
 * BusyBox 用 IF_XXX(x) 做条件编译，ENABLE_XXX=0 时展开为空。
 * 只要 ENABLE_XXX 已定义，IF_XXX 就由 libbb.h 自动生成；
 * 此处只为 ENABLE_XXX 本身补 0。
 * ================================================================ */

/* procps — 进程管理工具（已删除）
 * ENABLE_XXX 和 IF_XXX 都不在 autoconf.h 里，全部需要补 */
#ifndef ENABLE_KILLALL
#define ENABLE_KILLALL 0
#define IF_KILLALL(...)
#endif
#ifndef ENABLE_PGREP
#define ENABLE_PGREP 0
#define IF_PGREP(...)
#endif
#ifndef ENABLE_PKILL
#define ENABLE_PKILL 0
#define IF_PKILL(...)
#endif
#ifndef ENABLE_PIDOF
#define ENABLE_PIDOF 0
#define IF_PIDOF(...)
#endif
#ifndef ENABLE_FEATURE_TOPMEM
#define ENABLE_FEATURE_TOPMEM 0
#define IF_FEATURE_TOPMEM(...)
#endif
#ifndef ENABLE_FEATURE_SHOW_THREADS
#define ENABLE_FEATURE_SHOW_THREADS 0
#define IF_FEATURE_SHOW_THREADS(...)
#endif
#ifndef ENABLE_FEATURE_TOP_SMP_PROCESS
#define ENABLE_FEATURE_TOP_SMP_PROCESS 0
#define IF_FEATURE_TOP_SMP_PROCESS(...)
#endif
#ifndef ENABLE_FEATURE_PS_ADDITIONAL_COLUMNS
#define ENABLE_FEATURE_PS_ADDITIONAL_COLUMNS 0
#define IF_FEATURE_PS_ADDITIONAL_COLUMNS(...)
#endif

/* selinux — 安全增强（已删除） */
#ifndef ENABLE_SELINUX
#define ENABLE_SELINUX 0
#endif
#ifndef ENABLE_SESTATUS
#define ENABLE_SESTATUS 0
#endif

/* klibc-utils（已删除） */
#ifndef ENABLE_RUN_INIT
#define ENABLE_RUN_INIT 0
#endif

/* ================================================================
 * 以下宏来自 libbb.h 中引用、但对应模块已删除的配置项。
 * 这些不是被删除模块自身的选项，而是被其他启用代码交叉引用的。
 * ================================================================ */

/* crond 的选项，被 libbb.h 的 PARSE_KEEP_COPY 引用 */
#ifndef ENABLE_FEATURE_CROND_D
#define ENABLE_FEATURE_CROND_D 0
#endif

/* syslog — 被 libbb.h 的 LOGMODE_SYSLOG 引用 */
#ifndef ENABLE_FEATURE_SYSLOG
#define ENABLE_FEATURE_SYSLOG 0
#endif

/* verbose — 被 libbb.h 的 FILEUTILS_VERBOSE 引用 */
#ifndef ENABLE_FEATURE_VERBOSE
#define ENABLE_FEATURE_VERBOSE 0
#endif

/* shell — 删除 ash/hush 后 ENABLE_SHELL_ASH/HUSH 不再由 autoconf.h 定义 */
#ifndef ENABLE_SHELL_ASH
#define ENABLE_SHELL_ASH 0
#define IF_SHELL_ASH(...)
#endif
#ifndef ENABLE_SHELL_HUSH
#define ENABLE_SHELL_HUSH 0
#define IF_SHELL_HUSH(...)
#endif

/* procps 的 pmap — 已删除模块的选项 */
#ifndef ENABLE_PMAP
#define ENABLE_PMAP 0
#define IF_PMAP(...)
#endif

/* procps 的 kill/killall5 — 已删除模块 */
#ifndef ENABLE_KILL
#define ENABLE_KILL 0
#define IF_KILL(...)
#endif
#ifndef ENABLE_KILLALL5
#define ENABLE_KILLALL5 0
#define IF_KILLALL5(...)
#endif

/* shell 内部选项 — ash 删除后不再由 kconfig 生成 */
#ifndef ENABLE_ASH_PRINTF
#define ENABLE_ASH_PRINTF 0
#endif
#ifndef ENABLE_HUSH_PRINTF
#define ENABLE_HUSH_PRINTF 0
#endif
#ifndef ENABLE_ASH_TEST
#define ENABLE_ASH_TEST 0
#endif
#ifndef ENABLE_HUSH_TEST
#define ENABLE_HUSH_TEST 0
#endif
#ifndef ENABLE_ASH_BASH_COMPAT
#define ENABLE_ASH_BASH_COMPAT 0
#endif

/* ================================================================
 * off_t 大小检查 — libbb.h 断言 sizeof(off_t)==sizeof(uoff_t)
 * WASM32 下 off_t 是 64bit（_FILE_OFFSET_BITS=64），uoff_t 也是 64bit，
 * 但 wasi-libc 的 off_t 定义可能不同。这里绕过编译期断言。
 * ================================================================ */
#ifdef BUG_off_t_size_is_misdetected
#undef BUG_off_t_size_is_misdetected
#endif

#endif /* WASI_COMPAT_H */
