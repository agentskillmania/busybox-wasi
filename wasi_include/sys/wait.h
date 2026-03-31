/* Stub sys/wait.h for WASI */
#ifndef _SYS_WAIT_H
#define _SYS_WAIT_H

#include <sys/types.h>

#define WNOHANG      1
#define WUNTRACED    2
#define WCONTINUED   8

#define WIFEXITED(s)    ((s) & 0x7f)
#define WTERMSIG(s)    ((s) & 0x7f)
#define WIFSIGNALED(s) (((signed char) (((s) & 0x7f) + 1) >> 1) > 0)

static inline pid_t waitpid(pid_t pid, int *status, int options) {
    if (status) *status = 0;
    return -1;
}
static inline pid_t wait(int *status) {
    return waitpid(-1, status, 0);
}

#endif
