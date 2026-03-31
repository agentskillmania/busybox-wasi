#ifndef _SYS_STATVFS_H
#define _SYS_STATVFS_H

#include <sys/types.h>

struct statvfs {
    unsigned long f_bsize;
    unsigned long f_frsize;
    unsigned long f_blocks;
    unsigned long f_bfree;
    unsigned long f_bavail;
    unsigned long f_files;
    unsigned long f_ffree;
    unsigned long f_favail;
    unsigned long f_fsid;
    unsigned long f_flag;
    unsigned long f_namemax;
};

static inline int statvfs(const char *p, struct statvfs *b) { (void)p; (void)b; return -1; }
static inline int fstatvfs(int fd, struct statvfs *b) { (void)fd; (void)b; return -1; }

#endif
