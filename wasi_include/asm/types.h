#ifndef _ASM_TYPES_H
#define _ASM_TYPES_H

/* 提供与 linux/types.h 一致的类型定义，用于 fix_u32.h 等 busybox 内部头文件 */
typedef unsigned char      __u8;
typedef unsigned short     __u16;
typedef unsigned int       __u32;
typedef unsigned long long __u64;
typedef signed char        __s8;
typedef signed short       __s16;
typedef signed int         __s32;
typedef signed long long   __s64;

typedef __u32 __kernel_dev_t;
typedef __u32 __kernel_ino_t;
typedef __u32 __kernel_mode_t;
typedef __u32 __kernel_nlink_t;
typedef long  __kernel_off_t;
typedef int   __kernel_pid_t;
typedef __u32 __kernel_uid_t;
typedef __u32 __kernel_gid_t;
typedef __u32 __kernel_daddr_t;
typedef __u64 __kernel_loff_t;

#endif
