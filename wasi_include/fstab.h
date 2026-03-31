#ifndef _FSTAB_H
#define _FSTAB_H
struct fstab { char *fs_spec, *fs_file, *fs_vfstype, *fs_mntops; int fs_freq, fs_passno; };
static inline struct fstab *getfsent(void) { return NULL; }
static inline struct fstab *getfsspec(const char *n) { return NULL; }
static inline struct fstab *getfsfile(const char *n) { return NULL; }
static inline int setfsent(void) { return 1; }
#endif
