#ifndef _SYS_POLL_H
#define _SYS_POLL_H

#define POLLIN 1
#define POLLPRI 2
#define POLLOUT 4
#define POLLERR 8
#define POLLHUP 16
#define POLLNVAL 32

typedef unsigned long nfds_t;

struct pollfd { int fd; short events; short revents; };

static inline int poll(struct pollfd *f, nfds_t n, int t) { (void)f; (void)n; (void)t; return -1; }

#endif
