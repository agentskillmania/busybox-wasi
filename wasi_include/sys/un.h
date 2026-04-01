/*
 * BusyBox WASM 构建 - sys/un.h 包装器
 *
 * preview2 的 sockaddr_un 缺少 sun_path 字段（WASI 不支持 Unix domain socket）。
 * 本文件阻止 preview2 的不完整定义，然后提供包含 sun_path 的完整版本。
 */
#ifndef _WASM_SYS_UN_H
#define _WASM_SYS_UN_H

/* 阻止 preview2 定义不完整的 sockaddr_un */
#define __wasilibc___struct_sockaddr_un_h

/* 包含 preview2 的 sys/un.h（SUN_LEN 等） */
#include_next <sys/un.h>

/* 提供完整的 sockaddr_un */
struct sockaddr_un {
    sa_family_t sun_family;
    char sun_path[108];
};

#endif
