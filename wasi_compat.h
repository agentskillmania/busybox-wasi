/*
 * WASI 函数声明补丁。
 *
 * WASI 的头文件在某些条件下不声明 mknod、execl 等函数，
 * 导致 busybox 代码中产生隐式声明，编译器推断的参数类型
 * 与实际库函数签名不一致，链接时报 function signature mismatch。
 *
 * 通过在编译时 -include 此文件，提前声明这些函数，避免隐式声明。
 */
#ifndef WASI_COMPAT_H
#define WASI_COMPAT_H

#include <sys/types.h>
#include <stdarg.h>

/* mknod — WASI 条件性隐藏 */
int mknod(const char *path, mode_t mode, dev_t dev);
int mknodat(int dirfd, const char *path, mode_t mode, dev_t dev);

/* execl/execlp/execle — 变参函数需要正确声明 */
int execl(const char *path, const char *arg, ... /* (char *) NULL */);
int execlp(const char *file, const char *arg, ... /* (char *) NULL */);
int execle(const char *path, const char *arg, ... /* (char *) NULL, char *const envp[] */);

#endif
