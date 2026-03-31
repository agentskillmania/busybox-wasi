#ifndef _NETINET_IN_H
#define _NETINET_IN_H

#include <stdint.h>
#include <sys/socket.h>

struct in_addr { uint32_t s_addr; };
struct in6_addr { uint8_t s6_addr[16]; };

/* sockaddr_in 需要 sa_family_t，来自 sys/socket.h 或自行定义 */
#ifndef __sa_family_t_defined
#define __sa_family_t_defined
typedef unsigned short sa_family_t;
#endif

struct sockaddr_in {
    sa_family_t sin_family;
    uint16_t sin_port;
    struct in_addr sin_addr;
    char sin_zero[8];
};

struct sockaddr_in6 {
    sa_family_t sin6_family;
    uint16_t sin6_port;
    uint32_t sin6_flowinfo;
    struct in6_addr sin6_addr;
    uint32_t sin6_scope_id;
};

#define IPPROTO_IP    0
#define IPPROTO_ICMP  1
#define IPPROTO_TCP   6
#define IPPROTO_UDP   17
#define IPPROTO_IPV6  41
#define IPPROTO_RAW   255

#define INADDR_ANY       ((uint32_t)0x00000000)
#define INADDR_BROADCAST ((uint32_t)0xffffffff)
#define INADDR_LOOPBACK  ((uint32_t)0x7f000001)
#define INADDR_NONE      ((uint32_t)0xffffffff)

#define INET_ADDRSTRLEN  16
#define INET6_ADDRSTRLEN 46

#define IPV6_V6ONLY    26
#define IPV6_UNICAST_IF 76

#define IP_MULTICAST_IF    32
#define IP_MULTICAST_TTL   33
#define IP_MULTICAST_LOOP  34
#define IP_ADD_MEMBERSHIP  35
#define IP_DROP_MEMBERSHIP 36

#define IPV6_JOIN_GROUP    20
#define IPV6_LEAVE_GROUP   21

/* IP_PKTINFO 相关定义 */
#define IP_PKTINFO 8
#define IP_TOS 1
#define IP_TTL 2
#define IP_MULTICAST_IF 32

struct in_pktinfo {
    int ipi_ifindex;
    struct in_addr ipi_spec_dst;
    struct in_addr ipi_addr;
};

struct ipv6_mreq {
    struct in6_addr ipv6mr_multiaddr;
    unsigned ipv6mr_interface;
};

struct ip_mreq {
    struct in_addr imr_multiaddr;
    struct in_addr imr_interface;
};

/* TCP 常量 */
#define TCP_NODELAY    1
#define TCP_MAXSEG     2
#define TCP_KEEPIDLE   4
#define TCP_KEEPINTVL  5
#define TCP_KEEPCNT    6

/* 端口常量 */
#define IPPORT_RESERVED 1024

#endif
