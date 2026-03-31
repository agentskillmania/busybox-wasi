#ifndef _SYS_SEM_H
#define _SYS_SEM_H

#include <sys/ipc.h>

/* 信号量操作 */
#define SEM_GETVAL  1
#define SEM_SETVAL  2
#define SEM_GETPID  3
#define SEM_GETNCNT 4
#define SEM_UNDO   1

#define SEM_RMID   0

#define SEMAPHORE_UNLOCK 1

/* semunbuf 结构体 */
struct semun {
    short sem_num;
    short sem_op;
    short sem_flg;
    union {
        int val;
    } sem_val;
};

/* sembuf 结构体 */
struct sembuf {
    unsigned short sem_num;
    short sem_op;
    short sem_flg;
    union {
        int val;
    } sem_val;
};

#ifdef __cplusplus
extern "C" {
#endif

static inline int semget(key_t key, int sem_num, int sem_flg, void *ptr) { return -1; }
static inline int semop(key_t key, struct sembuf *sops, size_t nops) { return -1; }
static inline int semctl(key_t key, int cmd, ...) { return -1; }

static inline int semtimedop(key_t key, const struct timespec *timeout) { return -1; }

static inline int semtimed(key_t key, const struct timespec *timeout) { return -1; }

static inline key_t ftok(const char *path, int id) { return 0; }

static inline key_t keyall(int id) { return 0; }

static inline key_t keycl(int id) { return 0; }
static inline key_t keysnd(int id) { return 0; }
static inline key_t keyrcv(int id) { return 0; }
static inline int sem_join(int semid) { return -1; }
static inline int sem_trywait(int semid) { return -1; }
static inline int sem_wait(int semid) { return -1; }

#ifdef __cplusplus
}
#endif

#endif
