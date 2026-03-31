#ifndef _LINUX_NETLINK_H
#define _LINUX_NETLINK_H

#include <stdint.h>

#define NETLINK_KOBJECT_UEVENT 15

#define AF_NETLINK 16

struct sockaddr_nl {
    int nl_family;
    unsigned short nl_pad;
    uint32_t nl_pid;
    uint32_t nl_groups;
};

struct nlmsghdr {
    uint32_t nlmsg_len;
    uint16_t nlmsg_type;
    uint16_t nlmsg_flags;
    uint32_t nlmsg_seq;
    uint32_t nlmsg_pid;
};

#define NLMSG_ALIGNTO   4
#define NLMSG_ALIGN(len) (((len) + NLMSG_ALIGNTO - 1) & ~(NLMSG_ALIGNTO - 1))
#define NLMSG_HDRLEN    ((int)NLMSG_ALIGN(sizeof(struct nlmsghdr)))
#define NLMSG_LENGTH(len) ((len) + NLMSG_ALIGN(sizeof(struct nlmsghdr)))
#define NLMSG_SPACE(len) NLMSG_ALIGN(NLMSG_LENGTH(len))
#define NLMSG_DATA(nlh) ((void *)((char *)(nlh) + NLMSG_HDRLEN))
#define NLMSG_NEXT(nlh, len) ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
                              (struct nlmsghdr *)(((char *)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
#define NLMSG_OK(nlh, len) ((len) >= (int)sizeof(struct nlmsghdr) && \
                            (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
                            (nlh)->nlmsg_len <= (len))

/* RTM_* 常量 */
#define RTMGRP_LINK          1
#define RTMGRP_NOTIFY        2
#define RTMGRP_NEIGH         4
#define RTMGRP_TC            8

#define NLM_F_REQUEST    1
#define NLM_F_MULTI      2
#define NLM_F_ACK        4

#define RTM_GETLINK      18
#define RTM_NEWLINK      16
#define RTM_DELLINK      17
#define RTM_GETADDR      22
#define RTM_NEWADDR      20
#define RTM_DELADDR      21

#endif
