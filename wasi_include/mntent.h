#ifndef _MNTENT_H
#define _MNTENT_H
#include <stdio.h>
struct mntent { char *mnt_fsname, *mnt_dir, *mnt_type, *mnt_opts; int mnt_freq, mnt_passno; };
static inline FILE *setmntent(const char *f, const char *m) { return NULL; }
static inline struct mntent *getmntent(FILE *s) { return NULL; }
static inline int endmntent(FILE *s) { return 1; }
#endif
