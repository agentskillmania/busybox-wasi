#ifndef _ARPA_INET_H
#define _ARPA_INET_H
#include <netinet/in.h>
static inline unsigned long inet_addr(const char *cp) { return -1; }
static inline char *inet_ntoa(struct in_addr in) { return NULL; }
static inline int inet_aton(const char *cp, struct in_addr *inp) { return 0; }
#endif
