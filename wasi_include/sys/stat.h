/*
 * 本地 sys/stat.h 补丁。
 *
 * 先包含 wasi-sdk 原始的 stat.h，再补充 mknod/mknodat 声明。
 * wasi-libc 的 stat.h 将 mknod 隐藏在 __wasilibc_unmodified_upstream 宏后面，
 * busybox 需要这些声明。
 *
 * 通过 -I wasi_include 让编译器优先找到此文件。
 */
#include_next <sys/stat.h>

#ifndef _BUSYBOX_WASM_STAT_H
#define _BUSYBOX_WASM_STAT_H

int mknod(const char *, mode_t, dev_t);
int mknodat(int, const char *, mode_t, dev_t);

#endif
