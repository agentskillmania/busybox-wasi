#ifndef _NETINET_ETHER_H
#define _NETINET_ETHER_H

#include <stdint.h>
#include <stddef.h>

struct ether_addr {
    uint8_t octet[6];
};

static inline char *ether_ntoa(const struct ether_addr *addr) { return NULL; }
static inline struct ether_addr *ether_aton(const char *asc) { return NULL; }

#endif
