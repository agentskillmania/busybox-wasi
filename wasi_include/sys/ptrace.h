#ifndef _SYS_PTRACE_H
#define _SYS_PTRACE_H
static inline int ptrace(int r, pid_t p, void *a, void *d) { return -1; }
#endif
