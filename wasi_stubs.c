/*
 * WASI POSIX stub 实现。
 *
 * 提供_busybox_wasm 链接时需要的 POSIX 函数 stub。
 * 这些函数在 WASI 中不存在或只有部分实现。
 * 所有 stub 返回安全默认值，让 busybox 能链接和基本运行。
 */
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
/* setjmp/longjmp stub — 不使用 wasm EH，避免 wasmtime legacy exceptions 问题。
 * longjmp 被调用时直接退出进程（正常路径不会触发 longjmp）。*/

int setjmp(void *env) {
    (void)env;
    return 0;
}

void longjmp(void *env, int val) {
    (void)env; (void)val;
    _exit(128);
    __builtin_unreachable();
}

int sigsetjmp(void *env, int savemask) {
    (void)savemask;
    return setjmp(env);
}

void siglongjmp(void *env, int val) {
    longjmp(env, val);
}

/* ========== 网络相关 stub ========== */

int socket(int domain, int type, int protocol) {
    (void)domain; (void)type; (void)protocol;
    errno = ENOSYS;
    return -1;
}

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    (void)sockfd; (void)addr; (void)addrlen;
    errno = ENOSYS;
    return -1;
}

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    (void)sockfd; (void)addr; (void)addrlen;
    errno = ENOSYS;
    return -1;
}

int listen(int sockfd, int backlog) {
    (void)sockfd; (void)backlog;
    errno = ENOSYS;
    return -1;
}

ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
               const struct sockaddr *dest_addr, socklen_t addrlen) {
    (void)sockfd; (void)buf; (void)len; (void)flags;
    (void)dest_addr; (void)addrlen;
    errno = ENOSYS;
    return -1;
}

ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,
                 struct sockaddr *src_addr, socklen_t *addrlen) {
    (void)sockfd; (void)buf; (void)len; (void)flags;
    (void)src_addr; (void)addrlen;
    errno = ENOSYS;
    return -1;
}

ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags) {
    (void)sockfd; (void)msg; (void)flags;
    errno = ENOSYS;
    return -1;
}

ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags) {
    (void)sockfd; (void)msg; (void)flags;
    errno = ENOSYS;
    return -1;
}

int setsockopt(int sockfd, int level, int optname,
               const void *optval, socklen_t optlen) {
    (void)sockfd; (void)level; (void)optname; (void)optval; (void)optlen;
    errno = ENOSYS;
    return -1;
}

int getsockname(int sockfd, struct sockaddr *addr, socklen_t *addrlen) {
    (void)sockfd; (void)addr; (void)addrlen;
    errno = ENOSYS;
    return -1;
}

int getpeername(int sockfd, struct sockaddr *addr, socklen_t *addrlen) {
    (void)sockfd; (void)addr; (void)addrlen;
    errno = ENOSYS;
    return -1;
}

/* ========== 信号管理 stub ========== */

int sigaction(int sig, const struct sigaction *act, struct sigaction *oact) {
    (void)sig; (void)act; (void)oact;
    return 0;
}

int sigprocmask(int how, const sigset_t *set, sigset_t *oset) {
    (void)how; (void)set; (void)oset;
    return 0;
}

int sigemptyset(sigset_t *set) { (void)set; return 0; }
int sigfillset(sigset_t *set) { (void)set; return 0; }
int sigaddset(sigset_t *set, int signo) { (void)set; (void)signo; return 0; }
int sigdelset(sigset_t *set, int signo) { (void)set; (void)signo; return 0; }
int sigismember(const sigset_t *set, int signo) { (void)set; (void)signo; return 0; }
int sigisemptyset(const sigset_t *set) { (void)set; return 1; }

int sigsuspend(const sigset_t *mask) {
    (void)mask;
    errno = EINTR;
    return -1;
}

/* ========== 进程管理 stub ========== */

uid_t geteuid(void) { return 0; }
uid_t getuid(void) { return 0; }
gid_t getegid(void) { return 0; }
gid_t getgid(void) { return 0; }
pid_t getppid(void) { return 0; }
pid_t getpgrp(void) { return 0; }
pid_t getsid(pid_t pid) { (void)pid; return 0; }

int seteuid(uid_t uid) { (void)uid; return 0; }
int setegid(gid_t gid) { (void)gid; return 0; }
int setuid(uid_t uid) { (void)uid; return 0; }
int setgid(gid_t gid) { (void)gid; return 0; }
int setpgid(pid_t pid, pid_t pgid) { (void)pid; (void)pgid; return 0; }
pid_t setsid(void) { return 0; }
int setpgrp(void) { return 0; }

int setgroups(size_t size, const gid_t *list) { (void)size; (void)list; return 0; }
int getgroups(int size, gid_t *list) { (void)size; (void)list; return 0; }
int getgrouplist(const char *user, gid_t group, gid_t *groups, int *ngroups) {
    (void)user; (void)group; (void)groups;
    if (ngroups) *ngroups = 1;
    return 1;
}
int setresuid(uid_t ruid, uid_t euid, uid_t suid) { (void)ruid; (void)euid; (void)suid; return 0; }
int setresgid(gid_t rgid, gid_t egid, gid_t sgid) { (void)rgid; (void)egid; (void)sgid; return 0; }

int kill(pid_t pid, int sig) { (void)pid; (void)sig; errno = ENOSYS; return -1; }

pid_t vfork(void) { errno = ENOSYS; return -1; }
pid_t fork(void) { errno = ENOSYS; return -1; }

pid_t wait3(int *status, int options, void *rusage) {
    (void)status; (void)options; (void)rusage;
    errno = ECHILD;
    return -1;
}

int WEXITSTATUS(int status) { (void)status; return 0; }

/* ========== 文件/IO stub ========== */

int pipe(int fd[2]) { (void)fd; errno = ENOSYS; return -1; }
int dup(int oldfd) { (void)oldfd; errno = ENOSYS; return -1; }
int dup2(int oldfd, int newfd) { (void)oldfd; (void)newfd; errno = ENOSYS; return -1; }

int flock(int fd, int operation) { (void)fd; (void)operation; return 0; }

int mkstemp(char *template) {
    (void)template;
    errno = ENOSYS;
    return -1;
}

char *mktemp(char *template) {
    (void)template;
    return NULL;
}

int mkdtemp(char *template) {
    (void)template;
    errno = ENOSYS;
    return -1;
}

int mkfifo(const char *pathname, mode_t mode) {
    (void)pathname; (void)mode;
    errno = ENOSYS;
    return -1;
}

int chroot(const char *path) { (void)path; errno = ENOSYS; return -1; }
int pivot_root(const char *new_root, const char *put_old) {
    (void)new_root; (void)put_old; errno = ENOSYS; return -1;
}

int fchdir(int fd) { (void)fd; errno = ENOSYS; return -1; }

mode_t umask(mode_t mask) { (void)mask; return 022; }

void sync(void) { }
int syncfs(int fd) { (void)fd; return 0; }

/* ========== exec 家族 stub ========== */

int execve(const char *pathname, char *const argv[], char *const envp[]) {
    (void)pathname; (void)argv; (void)envp;
    errno = ENOSYS;
    return -1;
}

int execvp(const char *file, char *const argv[]) {
    (void)file; (void)argv;
    errno = ENOSYS;
    return -1;
}

int execv(const char *pathname, char *const argv[]) {
    (void)pathname; (void)argv;
    errno = ENOSYS;
    return -1;
}

int execl(const char *path, const char *arg, ...) {
    (void)path; (void)arg;
    errno = ENOSYS;
    return -1;
}

int execle(const char *path, const char *arg, ...) {
    (void)path; (void)arg;
    errno = ENOSYS;
    return -1;
}

int execlp(const char *file, const char *arg, ...) {
    (void)file; (void)arg;
    errno = ENOSYS;
    return -1;
}

/* ========== 用户/权限 stub ========== */

int getpriority(int which, id_t who) { (void)which; (void)who; return 0; }
int setpriority(int which, id_t who, int prio) { (void)which; (void)who; (void)prio; return 0; }
int nice(int inc) { (void)inc; errno = ENOSYS; return -1; }

int getrlimit(int resource, void *rlim) { (void)resource; (void)rlim; errno = ENOSYS; return -1; }
int setrlimit(int resource, const void *rlim) { (void)resource; (void)rlim; errno = ENOSYS; return -1; }

int sethostname(const char *name, size_t len) { (void)name; (void)len; errno = ENOSYS; return -1; }
int settimeofday(const struct timeval *tv, const struct timezone *tz) {
    (void)tv; (void)tz; errno = ENOSYS; return -1;
}
int clock_settime(clockid_t clk_id, const struct timespec *tp) {
    (void)clk_id; (void)tp; errno = ENOSYS; return -1;
}

/* ========== 网络/接口 stub ========== */

const char *hstrerror(int err) { (void)err; return "unknown error"; }
unsigned int if_nametoindex(const char *ifname) { (void)ifname; return 0; }
struct hostent *ether_aton_r(const char *asc, void *buf) {
    (void)asc; (void)buf; return NULL;
}

/* ========== 终端/TTY stub ========== */

int tcsetpgrp(int fd, pid_t pgrp) { (void)fd; (void)pgrp; return 0; }
pid_t tcgetpgrp(int fd) { (void)fd; return 0; }
int tcgetsid(int fd) { (void)fd; return 0; }
int cfsetspeed(void *termios_p, unsigned long speed) {
    (void)termios_p; (void)speed; return 0;
}
char *ttyname_r(int fd, char *buf, size_t buflen) {
    (void)fd; (void)buflen;
    if (buf) buf[0] = '\0';
    return NULL;
}

/* ========== 杂项 stub ========== */

int *__h_errno_location(void) {
    static int h_errno_val = 0;
    return &h_errno_val;
}

int adjtimex(void *buf) { (void)buf; errno = ENOSYS; return -1; }
unsigned int alarm(unsigned int seconds) { (void)seconds; return 0; }
int pause(void) { errno = EINTR; return -1; }
int readahead(int fd, off_t offset, size_t count) {
    (void)fd; (void)offset; (void)count; errno = ENOSYS; return -1;
}

int sched_getaffinity(pid_t pid, size_t cpusetsize, void *mask) {
    (void)pid; (void)cpusetsize; (void)mask; errno = ENOSYS; return -1;
}
int sched_setaffinity(pid_t pid, size_t cpusetsize, const void *mask) {
    (void)pid; (void)cpusetsize; (void)mask; errno = ENOSYS; return -1;
}

long sysinfo(void *info) { (void)info; errno = ENOSYS; return -1; }
int system(const char *command) { (void)command; errno = ENOSYS; return -1; }

int getlogin_r(char *buf, size_t buflen) {
    (void)buflen;
    if (buf) { buf[0] = '\0'; }
    return 0;
}

char *getusershell(void) { return NULL; }
void endusershell(void) { }
void setusershell(void) { }

int grantpt(int fd) { (void)fd; return 0; }
int unlockpt(int fd) { (void)fd; return 0; }
char *ptsname_r(int fd, char *buf, size_t buflen) {
    (void)fd; (void)buflen;
    if (buf) buf[0] = '\0';
    return NULL;
}

int utmpxname(const char *file) { (void)file; return -1; }
void updwtmpx(const char *wtmpx_file, void *ut) { (void)wtmpx_file; (void)ut; }
void pututxline(void *ut) { (void)ut; }

void tzset(void) { }

FILE *popen(const char *command, const char *type) {
    (void)command; (void)type; errno = ENOSYS; return NULL;
}
int pclose(FILE *stream) { (void)stream; errno = ENOSYS; return -1; }

/* ========== 文件属主 stub ========== */

int chown(const char *path, uid_t owner, gid_t group) {
    (void)path; (void)owner; (void)group; return 0;
}
int lchown(const char *path, uid_t owner, gid_t group) {
    (void)path; (void)owner; (void)group; return 0;
}
int fchown(int fd, uid_t owner, gid_t group) {
    (void)fd; (void)owner; (void)group; return 0;
}

/* ========== 设备节点 stub ========== */

int mknod(const char *path, mode_t mode, dev_t dev) {
    (void)path; (void)mode; (void)dev; errno = ENOSYS; return -1;
}
int mknodat(int dirfd, const char *path, mode_t mode, dev_t dev) {
    (void)dirfd; (void)path; (void)mode; (void)dev; errno = ENOSYS; return -1;
}

/* ========== 用户组初始化 stub ========== */

int initgroups(const char *user, gid_t group) {
    (void)user; (void)group; return 0;
}
