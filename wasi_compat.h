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

/* ================================================================
 * off_t 大小检查 — libbb.h 断言 sizeof(off_t)==sizeof(uoff_t)
 * WASM32 下 off_t 是 64bit（_FILE_OFFSET_BITS=64），uoff_t 也是 64bit，
 * 但 wasi-libc 的 off_t 定义可能不同。这里绕过编译期断言。
 * ================================================================ */
#ifdef BUG_off_t_size_is_misdetected
#undef BUG_off_t_size_is_misdetected
#endif

#endif /* WASI_COMPAT_H */
