#ifndef _NETINET_IF_ETHER_H
#define _NETINET_IF_ETHER_H

#include <stdint.h>

#define ETH_ALEN    6
#define ETH_HLEN    14
#define ETH_ZLEN    60
#define ETH_FRAME_LEN 1514
#define ETH_FCS_LEN 4

#define ETH_P_ALL    0x0003
#define ETH_P_IP     0x0800
#define ETH_P_ARP    0x0806
#define ETH_P_IPV6   0x86DD

struct ether_addr {
    uint8_t ether_addr_octet[ETH_ALEN];
};

struct ether_header {
    uint8_t  ether_dhost[ETH_ALEN];
    uint8_t  ether_shost[ETH_ALEN];
    uint16_t ether_type;
};

#define ARPHRD_ETHER    1
#define ARPHRD_LOOPBACK 772

#define ARPOP_REQUEST   1
#define ARPOP_REPLY     2

struct arphdr {
    uint16_t ar_hrd;
    uint16_t ar_pro;
    uint8_t  ar_hln;
    uint8_t  ar_pln;
    uint16_t ar_op;
};

#endif
