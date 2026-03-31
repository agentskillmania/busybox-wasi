#ifndef _SYS_PRCTL_H
#define _SYS_PRCTL_H

/* prctl 操作码 */
#define PR_SET_PDEATHSIG  1
#define PR_GET_PDEATHSIG  2
#define PR_GET_DUMPABLE   3
#define PR_SET_DUMPABLE   4
#define PR_GET_UNALIGN   5
#define PR_SET_UNALIGN   6
#define PR_GET_KEEPCAPS  7
#define PR_SET_KEEPCAPS  8
#define PR_GET_FPEMU     9
#define PR_SET_FPEMU    10
#define PR_GET_FPEXC    11
#define PR_SET_FPEXC    12
#define PR_GET_TIMING   13
#define PR_SET_TIMING   14
#define PR_SET_NAME     15
#define PR_GET_NAME     16
#define PR_GET_ENDIAN   19
#define PR_SET_ENDIAN   20
#define PR_GET_SECCOMP  21
#define PR_SET_SECCOMP  22

static inline int prctl(int o, ...) { return -1; }

#endif
