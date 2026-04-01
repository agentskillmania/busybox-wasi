/*
 * BusyBox WASM 构建 - resolv.h stub
 *
 * preview2 不提供 BIND resolver 库。
 * 提供最小声明让 BusyBox 的 nslookup 编译通过。
 * 实际 DNS 解析通过 getaddrinfo() 完成（preview2 libc 原生支持）。
 */
#ifndef _RESOLV_H
#define _RESOLV_H

#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>

/* res_state 结构体 */
struct __res_state {
    int options;
    int retrans;
    int retry;
    unsigned int nscount;
    struct sockaddr_in nsaddr_list[3];
    unsigned short id;
    char dnsrch[7][256];
    char defdname[256];
};

typedef struct __res_state *res_state;

extern struct __res_state _res;

#define RES_INIT     0x00000001
#define RES_DEBUG    0x00000002
#define RES_AAONLY   0x00000004
#define RES_USEVC    0x00000008
#define RES_PRIMARY  0x00000010
#define RES_IGNTC    0x00000020
#define RES_RECURSE  0x00000040
#define RES_DEFNAMES 0x00000080
#define RES_STAYOPEN 0x00000100
#define RES_DNSRCH   0x00000200

/* stub 函数 */
static inline int res_init(void) { return 0; }
static inline int res_query(const char *name, int class, int type,
                            unsigned char *answer, int anslen) {
    (void)name; (void)class; (void)type;
    (void)answer; (void)anslen;
    return -1;
}
static inline int res_search(const char *name, int class, int type,
                             unsigned char *answer, int anslen) {
    (void)name; (void)class; (void)type;
    (void)answer; (void)anslen;
    return -1;
}
static inline int res_mkquery(int op, const char *dname, int class, int type,
                              const unsigned char *data, int datalen,
                              const unsigned char *newrr, unsigned char *buf, int buflen) {
    (void)op; (void)dname; (void)class; (void)type;
    (void)data; (void)datalen; (void)newrr; (void)buf; (void)buflen;
    return -1;
}
static inline int res_send(const unsigned char *msg, int msglen,
                           unsigned char *answer, int anslen) {
    (void)msg; (void)msglen; (void)answer; (void)anslen;
    return -1;
}
static inline int dn_expand(const unsigned char *msg,
                            const unsigned char *eomorig,
                            const unsigned char *comp_dn,
                            char *exp_dn, int length) {
    (void)msg; (void)eomorig; (void)comp_dn; (void)exp_dn; (void)length;
    return -1;
}
static inline int dn_comp(const char *exp_dn, unsigned char *comp_dn,
                          int length, unsigned char **dnptrs,
                          unsigned char **lastdnptr) {
    (void)exp_dn; (void)comp_dn; (void)length;
    (void)dnptrs; (void)lastdnptr;
    return -1;
}

#endif
