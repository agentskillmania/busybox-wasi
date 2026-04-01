/*
 * BusyBox WASM 构建 - net/if.h stub
 *
 * preview2 不提供 net/if.h（网络接口头文件）。
 * 提供最小定义让 BusyBox 的网络代码编译通过。
 */
#ifndef _NET_IF_H
#define _NET_IF_H

#include <sys/socket.h>
#include <stddef.h>

/* 接口索引常量 */
#define IF_NAMESIZE 16
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
#define IFF_MASTER      0x400
#define IFF_SLAVE       0x800
#define IFF_MULTICAST   0x1000
#define IFF_PORTSEL     0x2000
#define IFF_AUTOMEDIA   0x4000
#define IFF_DYNAMIC     0x8000
#define IFF_LOWER_UP    0x10000
#define IFF_LOWER_DOWN  0x20000
#define IFF_DORMANT     0x40000
#define IFF_ECHO        0x80000

struct ifmap {
    unsigned long mem_start;
    unsigned long mem_end;
    unsigned short base_addr;
    char dma_channel;
    char port;
};

struct ifreq {
    union {
        char ifrn_name[IF_NAMESIZE];
        struct sockaddr ifru_addr;
    } ifr_ifrn;
    short ifr_flags;
    int ifr_ivalue;
    int ifr_mtu;
    struct ifmap ifru_map;
    char ifr_slave[IF_NAMESIZE];
    char ifru_newname[IF_NAMESIZE];
    char *ifr_data;
};

/* 接口名称转换 */
static inline unsigned int if_nametoindex(const char *ifname) {
    (void)ifname;
    return 0;
}

static inline char *if_indextoname(unsigned int ifindex, char *ifname) {
    (void)ifindex; (void)ifname;
    return NULL;
}

static inline struct if_nameindex *if_nameindex(void) {
    return NULL;
}

static inline void if_freenameindex(struct if_nameindex *ptr) {
    (void)ptr;
}

#endif
