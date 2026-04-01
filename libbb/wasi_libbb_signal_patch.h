/**
 * BusyBox WASM 构建 - libbb 信号补丁
 *
 * wasi-libc 的 struct sigaction/siginfo_t 被 __wasilibc_unmodified_upstream 鉗藏。
 * 本头文件提供这些定义，让 signals.c 和 bb_askpass.c 编译通过。
 */
#ifndef WASI_LIBBB_SIGNAL_PATCH_H
#define WASI_LIBBB_SIGNAL_PATCH_H

#include <sys/types.h>
#include <signal.h>

/* siginfo_t */
#ifndef _WASI_SIGINFO_T_DEFINED
#define _WASI_SIGINFO_T_DEFINED
typedef struct {
	int si_signo;
	int si_code;
	char __pad[128 - 2*sizeof(int) - sizeof(long)];
} siginfo_t;
#endif

/* struct sigaction */
#ifndef _WASI_STRUCT_SIGACTION_DEFINED
#define _WASI_STRUCT_SIGACTION_DEFINED
struct sigaction {
	void (*sa_handler)(int);
	void (*sa_sigaction)(int, siginfo_t *, void *);
	sigset_t sa_mask;
	int sa_flags;
	void (*sa_restorer)(void);
};
#endif
/* SA_* 常量 */
#ifndef SA_NOCLDSTOP
#define SA_NOCLDSTOP  1
#endif
#ifndef SA_NOCLDWAIT
#define SA_NOCLDWAIT  2
#endif
#ifndef SA_SIGINFO
#define SA_SIGINFO  4
#endif
#ifndef SA_RESTART
#define SA_RESTART  0x10000000
#endif
#ifndef SA_NODEFER
#define SA_NODEFER  0x40000000
#endif
#ifndef SIG_BLOCK
#define SIG_BLOCK   0
#endif
#ifndef SIG_UNBLOCK
#define SIG_UNBLOCK 1
#endif
#ifndef SIG_SETMASK
#define SIG_SETMASK 2
#endif
/* 函数声明 */
int sigaction_set(int sig, const struct sigaction *act);
int sigaction(int sig, const struct sigaction *act, struct sigaction *oact);
int sigprocmask(int how, const sigset_t *set, sigset_t *oset);
int sigfillset(sigset_t *set);
int sigemptyset(sigset_t *set);
int sigaddset(sigset_t *set, int signo);
int sigdelset(sigset_t *set, int signo);
int sigismember(const sigset_t *set, int signo);
int sigsuspend(const sigset_t *set);
int sigpending(sigset_t *set);
void sigaction_block(int sig);
void sigaction_unblock(int sig);
void sigaction_wait_for(int sig);
#endif
