#ifndef _LINUX_IF_PACKET_H
#define _LINUX_IF_PACKET_H

#include <stdint.h>

struct sockaddr_ll {
    unsigned short sll_family;
    unsigned short sll_protocol;
    int sll_ifindex;
    unsigned short sll_hatype;
    unsigned char sll_pkttype;
    unsigned char sll_halen;
    unsigned char sll_addr[8];
};

#define PACKET_HOST       0
#define PACKET_BROADCAST  1
#define PACKET_MULTICAST  2
#define PACKET_OTHERHOST  3
#define PACKET_OUTGOING   4
#define PACKET_LOOPBACK   5
#define PACKET_USER       6
#define PACKET_KERNEL     7

#define TP_STATUS_CSUMNOTREADY 0x02
#define TP_STATUS_KERNEL       0x01
#define PACKET_OTHERHOST  3
#define PACKET_OUTGOING   4
#define PACKET_LOOPBACK   5
#define PACKET_FASTROUTE  6

#define PACKET_ADD_MEMBERSHIP  1
#define PACKET_DROP_MEMBERSHIP 2
#define PACKET_RECV_OUTPUT     3

struct packet_mreq {
    int mr_ifindex;
    unsigned short mr_type;
    unsigned short mr_alen;
    unsigned char mr_address[8];
};

#endif
