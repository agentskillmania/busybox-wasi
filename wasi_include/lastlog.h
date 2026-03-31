#ifndef _LASTLOG_H
#define _LASTLOG_H
struct lastlog { time_t ll_time; char ll_line[8]; char ll_host[16]; };
#endif
