#ifndef _UTMPX_H
#define _UTMPX_H
#include <utmp.h>
#include <time.h>

/* utmpx 类型常量 */
#define EMPTY         0
#define RUN_LVL       1
#define BOOT_TIME     2
#define NEW_TIME      3
#define OLD_TIME      4
#define INIT_PROCESS  5
#define LOGIN_PROCESS 6
#define USER_PROCESS  7
#define DEAD_PROCESS  8

struct utmpx {
	short ut_type;
	int ut_pid;
	char ut_line[32];
	char ut_id[4];
	char ut_user[32];
	char ut_host[256];
	struct timeval ut_tv;
};

static inline struct utmpx *getutxent(void) { return NULL; }
static inline void endutxent(void) {}
static inline void setutxent(void) {}
#endif
