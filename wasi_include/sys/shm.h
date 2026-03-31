#ifndef _SYS_SHM_H
#define _SYS_SHM_H

#include <sys/ipc.h>
#include <stddef.h>

/* 共享内存命令 */
#define IPC_CREAT  01000
#define IPC_EXCL   02000
#define IPC_RMID    010000
#define IPC_STAT    040000
#define IPC_SET    020000

/* 共享内存标志 */
#define SHM_RDONLY  0
#define SHM_RND    2
#define SHM_HUGETLB  4

/* shmctl/shmat/shmdt/shmget 函数 */
#ifdef __cplusplus
extern "C" {
#endif

static inline int shmctl(int shmid, int cmd, ...) { return -1; }
static inline void *shmat(int shmid, const void *addr, int flags) { return (void*)-1; }
static inline int shmdt(int shmid) { return -1; }
static inline int shmget(key_t key, size_t size, int shmflg) { return -1; }

/* shm_open 已在 sys/mman.h 中声明，不再重复声明 */

#ifdef __cplusplus
}
#endif

#endif
