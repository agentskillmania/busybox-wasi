#ifndef _SYS_IPC_H
#define _SYS_IPC_H

#include <sys/types.h>

/* IPC 常量 */
#define IPC_CREAT  01000
#define IPC_EXCL  02000
#define IPC_NOWAIT 04000
#define IPC_RMID   010000
#define IPC_SET    020000
#define IPC_STAT   040000

/* IPC 键 */
#define IPC_PRIVATE ((key_t)0)

/* IPC 命令 (用于 semctl) */
#define GETPID   11
#define GETNCNT  3
#define SETVAL  8
#define SETALL  9

/* 权限位 */
#define SEM_R     0400
#define SEM_A     0200
#define IPC_64   0100

struct ipc_perm {
    key_t key;
    uid_t uid;
    gid_t gid;
    unsigned short mode;
    unsigned short seq;
};

struct semid_ds {
    struct ipc_perm sem_perm;
    time_t sem_otime;
    time_t sem_ctime;
    unsigned long sem_nsems;
};

#endif
