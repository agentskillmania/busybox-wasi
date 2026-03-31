#ifndef _SPAWN_H
#define _SPAWN_H
static inline int posix_spawn(pid_t *r, const char *p, void *fa, void *sa, char *const av[], char *const ev[]) { return -1; }
static inline int posix_spawnp(pid_t *r, const char *p, void *fa, void *sa, char *const av[], char *const ev[]) { return -1; }
#endif
