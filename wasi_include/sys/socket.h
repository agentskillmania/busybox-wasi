/*
 * BusyBox WASM 构建 - sys/socket.h 补丁
 *
 * preview2 的 sys/socket.h 用 __wasilibc_unmodified_upstream 保护了
 * 大量 socket 选项常量（SO_BROADCAST 等），导致它们不可用。
 * 本文件在 preview2 sys/socket.h 之后 include，补充缺失的定义。
 * 同时补充 sockaddr_un 的 sun_path 字段。
 */
#ifndef _WASM_SYS_SOCKET_PATCH_H
#define _WASM_SYS_SOCKET_PATCH_H

/* 先包含 preview2 sysroot 的 sys/socket.h */
#include_next <sys/socket.h>

/* 补充 preview2 缺失的 socket 选项常量 */
#ifndef SO_DEBUG
#define SO_DEBUG        1
#define SO_BROADCAST    6
#define SO_DONTROUTE    5
#define SO_OOBINLINE    10
#define SO_NO_CHECK     11
#define SO_PRIORITY     12
#define SO_LINGER       13
#define SO_BSDCOMPAT    14
#define SO_REUSEPORT    15
#define SO_PASSCRED     16
#define SO_PEERCRED     17
#define SO_RCVLOWAT     18
#define SO_SNDLOWAT     19
#endif

/* 补充缺失的 AF_ 地址族 */
#ifndef AF_LOCAL
#define AF_LOCAL        1
#define AF_UNIX         AF_LOCAL
#define AF_FILE         AF_LOCAL
#define AF_PACKET       17
#define AF_NETLINK      16
#endif

/* 补充缺失的 PF_ 协议族 */
#ifndef PF_LOCAL
#define PF_LOCAL        1
#define PF_UNIX         PF_LOCAL
#define PF_FILE         PF_LOCAL
#define PF_PACKET       17
#define PF_NETLINK      16
#endif

/* 补充缺失的 SOCK_ 类型 */
#ifndef SOCK_RAW
#define SOCK_RAW        3
#define SOCK_RDM        4
#define SOCK_SEQPACKET  5
#define SOCK_DCCP       6
#define SOCK_PACKET     10
#endif

/* MSG_ 常量 */
#ifndef MSG_DONTWAIT
#define MSG_DONTWAIT    0x0040
#endif
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL    0x4000
#endif
#ifndef MSG_PEEK
#define MSG_PEEK        0x0002
#endif
#ifndef MSG_WAITALL
#define MSG_WAITALL     0x0100
#endif
#ifndef MSG_TRUNC
#define MSG_TRUNC       0x0020
#endif

#endif
