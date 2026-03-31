#ifndef _SYS_SWAP_H
#define _SYS_SWAP_H
static inline int swapon(const char *p, int f) { return -1; }
static inline int swapoff(const char *p) { return -1; }
#endif
