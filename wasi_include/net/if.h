#ifndef _NET_IF_H
#define _NET_IF_H

#include <stdint.h>
#include <sys/socket.h>

#define IF_NAMESIZE 16

struct ifreq {
    char ifr_name[IF_NAMESIZE];
    union {
        struct sockaddr ifr_addr;
        struct sockaddr ifr_dstaddr;
        struct sockaddr ifr_broadaddr;
        struct sockaddr ifr_netmask;
        struct sockaddr ifr_hwaddr;
        short ifr_flags;
        int ifr_ifindex;
        int ifr_metric;
        int ifr_mtu;
        char ifr_slave[IF_NAMESIZE];
        char ifr_newname[IF_NAMESIZE];
        char *ifr_data;
    } ifr_ifru;
};

#define ifr_addr      ifr_ifru.ifr_addr
#define ifr_dstaddr   ifr_ifru.ifr_dstaddr
#define ifr_broadaddr ifr_ifru.ifr_broadaddr
#define ifr_netmask   ifr_ifru.ifr_netmask
#define ifr_hwaddr    ifr_ifru.ifr_hwaddr
#define ifr_flags     ifr_ifru.ifr_flags
#define ifr_ifindex   ifr_ifru.ifr_ifindex
#define ifr_metric    ifr_ifru.ifr_metric
#define ifr_mtu       ifr_ifru.ifr_mtu

struct ifconf {
    int ifc_len;
    union {
        char *ifc_buf;
    } ifc_ifcu;
};

#define ifc_buf ifc_ifcu.ifc_buf

/* ioctl 码 */
#define SIOCGIFADDR    0x8915
#define SIOCSIFADDR    0x8916
#define SIOCGIFFLAGS   0x8913
#define SIOCSIFFLAGS   0x8914
#define SIOCGIFHWADDR  0x8927
#define SIOCSIFHWADDR  0x8924
#define SIOCGIFMTU     0x8921
#define SIOCSIFMTU     0x8922
#define SIOCGIFINDEX   0x8933
#define SIOCGIFCONF    0x8912

/* 接口标志 */
#define IFF_UP          0x1
#define IFF_BROADCAST   0x2
#define IFF_DEBUG       0x4
#define IFF_LOOPBACK    0x8
#define IFF_POINTOPOINT 0x10
#define IFF_NOTRAILERS  0x20
#define IFF_RUNNING     0x40
#define IFF_NOARP       0x80
#define IFF_PROMISC     0x100
#define IFF_ALLMULTI    0x200
#define IFF_MULTICAST   0x1000

#endif
