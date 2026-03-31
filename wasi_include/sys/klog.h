#ifndef _SYS_KLOG_H
#define _SYS_KLOG_H

/* syslog 常量 */
#define SYSLOG_ACTION_CLOSE         0
#define SYSLOG_ACTION_OPEN          1
#define SYSLOG_ACTION_READ          2
#define SYSLOG_ACTION_READ_ALL      3
#define SYSLOG_ACTION_READ_CLEAR    4
#define SYSLOG_ACTION_CONSOLE_OFF   6
#define SYSLOG_ACTION_CONSOLE_ON    7
#define SYSLOG_ACTION_SIZE_UNREAD   9
#define SYSLOG_ACTION_SIZE_BUFFER  10

static inline int klogctl(int type, char *buf, int len) { return -1; }

#endif
