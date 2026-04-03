/*
 * sys/resource.h — WASI 资源限制补丁
 *
 * WASI 没有 getrlimit/setrlimit 和相关定义。
 * shell_common.c 的 ulimit 功能（被 hush 引用）无条件编译这些结构体，
 * 所以需要提供类型和常量定义，函数由 wasi_stubs.c 提供空实现。
 */
#ifndef _SYS_RESOURCE_H
#define _SYS_RESOURCE_H

#include <sys/types.h>

/* rlim_t */
typedef unsigned long rlim_t;

#define RLIM_INFINITY ((rlim_t)-1)

/* struct rlimit */
struct rlimit {
	rlim_t rlim_cur;
	rlim_t rlim_max;
};

/* RLIMIT_* 常量 — 使用 Linux 值 */
#define RLIMIT_CPU      0
#define RLIMIT_FSIZE    1
#define RLIMIT_DATA     2
#define RLIMIT_STACK    3
#define RLIMIT_CORE     4
#define RLIMIT_RSS      5
#define RLIMIT_NPROC    6
#define RLIMIT_NOFILE   7
#define RLIMIT_MEMLOCK  8
#define RLIMIT_AS       9
#define RLIMIT_LOCKS    10
#define RLIMIT_SIGPENDING 11
#define RLIMIT_MSGQUEUE 12
#define RLIMIT_NICE     13
#define RLIMIT_RTPRIO   14
#define RLIMIT_RTTIME   15

#define RLIMIT_NLIMITS  16

/* 函数声明（实现在 wasi_stubs.c，返回 -1/ENOSYS） */
int getrlimit(int resource, struct rlimit *rlim);
int setrlimit(int resource, const struct rlimit *rlim);

#endif /* _SYS_RESOURCE_H */
