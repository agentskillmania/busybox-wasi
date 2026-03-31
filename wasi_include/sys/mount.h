#ifndef _SYS_MOUNT_H
#define _SYS_MOUNT_H
#define MS_RDONLY 1
static inline int mount(const char *s, const char *t, const char *f, unsigned long m, const void *d) { return -1; }
static inline int umount(const char *t) { return -1; }
static inline int umount2(const char *t, int f) { return -1; }
#endif
