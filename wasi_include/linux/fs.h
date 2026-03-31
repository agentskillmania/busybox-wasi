#ifndef _LINUX_FS_H
#define _LINUX_FS_H

#include <linux/types.h>

/* 文件系统相关常量和 ioctl */
#define BLKSSZGET    _IOR(0x12,104,__u32)
#define BLKGETSIZE64 _IOR(0x12,114,__u64)
#define BLKGETSIZE   _IOR(0x12,96,__u32)
#define BLKRRPART    _IO(0x12,95)
#define BLKFLSBUF    _IO(0x12,97)
#define BLKRASET     _IO(0x12,98)
#define BLKRAGET     _IO(0x12,99)
#define BLKFRASET    _IO(0x12,100)
#define BLKFRAGET    _IO(0x12,101)
#define BLKSECTSET   _IO(0x12,102)
#define BLKSECTGET   _IO(0x12,103)
#define BLKBSZGET    _IOR(0x12,112,__u32)
#define BLKBSZSET    _IOW(0x12,113,__u32)

#define FS_IOC_GETFLAGS _IOR('f',1,long)
#define FS_IOC_SETFLAGS _IOW('f',2,long)
#define FS_IMMUTABLE_FL 0x10
#define FS_APPEND_FL    0x20
#define FS_NOATIME_FL   0x80

/* 需要 _IOC/_IO/_IOR/_IOW 宏 */
#include <sys/ioctl.h>

#endif
