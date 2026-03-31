#ifndef _SYS_TIMEX_H
#define _SYS_TIMEX_H

#include <sys/types.h>

struct timex {
    int modes;
    long offset;
    long freq;
    long maxerror;
    long esterror;
    int status;
    long constant;
    long precision;
    long tolerance;
    long tick;
    long ppsfreq;
    long jitter;
    int shift;
    long stabil;
    long jitcnt;
    long calcnt;
    long errcnt;
    long stbcnt;
    int tai;
    struct timeval time;
};

/* ADJ 模式常量 */
#define ADJ_OFFSET       0x0001
#define ADJ_FREQUENCY    0x0002
#define ADJ_MAXERROR     0x0004
#define ADJ_ESTERROR     0x0008
#define ADJ_STATUS       0x0010
#define ADJ_TIMECONST    0x0020
#define ADJ_TICK         0x4000
#define ADJ_OFFSET_SINGLESHOT 0x8001

/* STA 状态常量 */
#define STA_PLL          0x0001
#define STA_PPSFREQ      0x0002
#define STA_PPSTIME      0x0004
#define STA_FLL          0x0008
#define STA_INS          0x0010
#define STA_DEL          0x0020
#define STA_UNSYNC       0x0040
#define STA_FREQHOLD     0x0080
#define STA_PPSSIGNAL    0x0100
#define STA_PPSJITTER    0x0200
#define STA_PPSWANDER    0x0400
#define STA_PPSERROR     0x0800
#define STA_CLOCKERR     0x1000

/* 返回值 */
#define TIME_OK  0
#define TIME_INS 1
#define TIME_DEL 2
#define TIME_OOP 3
#define TIME_WAIT 4
#define TIME_ERROR 5

static inline int adjtimex(struct timex *t) { (void)t; return -1; }

#endif
