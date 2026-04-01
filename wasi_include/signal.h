/**
 * BusyBox WASM 构建 - signal.h 补丁
 *
 * wasi-libc 用 __wasilibc_unmodified_upstream 鉊藏了几乎所有 POSIX signal 定义。
 * -D_WASI_EMULATED_SIGNAL 只 wasi-libc 只暴露基础的 signal.h，
 * 但该文件仍然有 struct sigaction/siginfo_t/sigset_t 被隐藏。
 *
 * 本文件在 wasi_include/ 中，通过 -I 优先于 wasi-libc 的 signal.h 被找到。
 * 完整提供 busybox 需要的所有 POSIX signal 定义。
 */
#ifndef _SIGNAL_H
#define _SIGNAL_H

#include <sys/types.h>
#include <stddef.h>

/* 信号编号 */
#define SIGHUP     1
#define SIGINT     2
#define SIGQUIT    3
#define SIGILL     4
#define SIGTRAP    5
#define SIGABRT    6
#define SIGBUS     7
#define SIGFPE     8
#define SIGKILL    9
#define SIGUSR1    10
#define SIGSEGV    11
#define SIGUSR2    12
#define SIGPIPE    13
#define SIGALRM    14
#define SIGTERM    15
#define SIGSTKFLT 16
#define SIGCHLD    17
#define SIGCONT    18
#define SIGSTOP    19
#define SIGTSTP    20
#define SIGTTIN    21
#define SIGTTOU    22
#define SIGURG     23
#define SIGXCPU    24
#define SIGXFSZ    25
#define SIGVTALRM 26
#define SIGPROF    27
#define SIGWINCH   28
#define SIGIO      29
#define SIGPWR     30
#define SIGSYS     31
#define SIGUNUSED  31
#define NSIG       32
#define SIG_DFL     ((void (*)(int)) 0)
#define SIG_IGN     ((void (*)(int)) 1)
#define SIG_ERR     ((void (*)(int)) -1)
/* sigset_t — 使用 wasi-libc 的定义（unsigned char）， * 通过 -isystem 或通过 __typedef_sigset_t.h 获得
 */
#ifndef _WASI_SIGSET_T_DEFINED
#include <__typedef_sigset_t.h>
#endif
/* siginfo_t */
typedef struct {
    int si_signo;
    int si_code;
    char __pad[128 - 2*sizeof(int) - sizeof(long)];
} siginfo_t;
/* SA_* 常量 */
#define SA_NOCLDSTOP  1
#define SA_NOCLDWAIT  2
#define SA_SIGINFO    4
#define SA_RESTART    0x10000000
#define SA_NODEFER    0x40000000
#define SA_ONSTACK    0x08000000
#define SIG_BLOCK     0
#define SIG_UNBLOCK  1
#define SIG_SETMASK   2
/* struct sigaction */
struct sigaction {
    void (*sa_handler)(int);
    void (*sa_sigaction)(int, siginfo_t *, void *);
    sigset_t sa_mask;
    int sa_flags;
    void (*sa_restorer)(void);
};
/* stack_t */
typedef struct {
    void *ss_sp;
    int ss_flags;
    size_t ss_size;
} stack_t;
/* 函数声明 */
void (*signal(int sig, void (*func)(int)))(int);
int kill(pid_t pid, int sig);
int raise(int sig);
unsigned int alarm(unsigned int seconds);
int pause(void);
unsigned int sleep(unsigned int seconds);
int sigemptyset(sigset_t *set);
int sigfillset(sigset_t *set);
int sigaddset(sigset_t *set, int signo);
int sigdelset(sigset_t *set, int signo);
int sigismember(const sigset_t *set, int signo);
int sigprocmask(int how, const sigset_t *set, sigset_t *oset);
int sigsuspend(const sigset_t *set);
int sigpending(sigset_t *set);
int sigaction(int sig, const struct sigaction *act, struct sigaction *oact);
int sigaltstack(const stack_t *ss, stack_t *oss);
#endif
