#ifndef _SYS_STATFS_H
#define _SYS_STATFS_H

#include <sys/types.h>

struct statfs {
    long f_type;
    long f_bsize;
    long f_blocks;
    long f_bfree;
    long f_bavail;
    long f_files;
    long f_ffree;
    long f_fsid;
    long f_namelen;
    long f_frsize;
    long f_flags;
    long f_spare[4];
};

static inline int statfs(const char *p, struct statfs *b) { return -1; }
static inline int fstatfs(int fd, struct statfs *b) { return -1; }

#endif
