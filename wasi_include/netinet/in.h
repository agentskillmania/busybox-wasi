/*
 * BusyBox WASM 构建 - netinet/in.h 包装器
 *
 * 包含 preview2 的 netinet/in.h，然后 undef IP_PKTINFO 和 IPV6_PKTINFO。
 * 这些宏导致 udp_io.c 使用 VLA-in-struct + cmsghdr 路径，
 * 在 WASM 中不支持。undef 后代码走简单的 sendto/recvfrom 路径。
 */
#ifndef _WASM_NETINET_IN_H
#define _WASM_NETINET_IN_H

/* 先包含 preview2 sysroot 的 netinet/in.h */
#include_next <netinet/in.h>

/* 禁用 PKTINFO，避免 udp_io.c 中的 VLA-in-struct 问题 */
#undef IP_PKTINFO
#undef IPV6_PKTINFO

#endif
