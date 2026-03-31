#ifndef _PTY_H
#define _PTY_H
static inline int forkpty(int *am, char *n, void *t, const void *w) { return -1; }
static inline int openpty(int *am, int *as, char *n, void *t, const void *w) { return -1; }
#endif
