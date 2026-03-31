#ifndef _UTMP_H
#define _UTMP_H
#define UT_LINESIZE 32
struct utmp { char ut_line[UT_LINESIZE]; char ut_user[UT_LINESIZE]; };
static inline struct utmp *getutent(void) { return NULL; }
static inline void endutent(void) {}
#endif
