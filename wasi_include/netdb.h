/* Stub netdb.h for WASI - provides minimal definitions to satisfy includes */
#ifndef _NETDB_H
#define _NETDB_H

#include <sys/socket.h>

/* Stub definitions */
#define AI_PASSIVE     0x0001
#define AI_CANONNAME   0x0002
#define AI_NUMERICHOST 0x0004
#define AI_V4MAPPED    0x0008
#define AI_ALL         0x0010
#define AI_ADDRCONFIG  0x0020

#define NI_NUMERICHOST 0x0001
#define NI_NUMERICSERV 0x0002
#define NI_NAMEREQD    0x0004
#define NI_DGRAM       0x0008

#define EAI_NONAME     -1
#define EAI_AGAIN      -2
#define EAI_FAIL       -3
#define EAI_FAMILY     -4
#define EAI_SYSTEM     -5

struct hostent {
    char  *h_name;
    char **h_aliases;
    int    h_addrtype;
    int    h_length;
    char **h_addr_list;
};

struct addrinfo {
    int              ai_flags;
    int              ai_family;
    int              ai_socktype;
    int              ai_protocol;
    socklen_t        ai_addrlen;
    struct sockaddr *ai_addr;
    char            *ai_canonname;
    struct addrinfo *ai_next;
};

/* servent 结构体 */
struct servent {
    char  *s_name;
    char **s_aliases;
    int    s_port;
    char  *s_proto;
};

/* protoent 结构体 */
struct protoent {
    char  *p_name;
    char **p_aliases;
    int    p_proto;
};

/* h_errno 变量 - 网络错误码 */
#define h_errno (*__h_errno_location())
#ifdef __cplusplus
extern "C" {
#endif
int *__h_errno_location(void);
#ifdef __cplusplus
}
#endif

#define HOST_NOT_FOUND 1
#define TRY_AGAIN      2
#define NO_RECOVERY    3
#define NO_DATA        4

/* Stub functions - always fail */
static inline struct hostent *gethostbyname(const char *name) { return NULL; }
static inline int getaddrinfo(const char *node, const char *service,
                              const struct addrinfo *hints, struct addrinfo **res) { return EAI_NONAME; }
static inline void freeaddrinfo(struct addrinfo *res) {}
static inline const char *gai_strerror(int errcode) { return "Address not available"; }
static inline int getnameinfo(const struct sockaddr *addr, socklen_t addrlen,
                              char *host, socklen_t hostlen, char *serv, socklen_t servlen, int flags) { return EAI_NONAME; }
static inline struct servent *getservbyname(const char *name, const char *proto) { return NULL; }
static inline struct servent *getservbyport(int port, const char *proto) { return NULL; }
static inline struct protoent *getprotobyname(const char *name) { return NULL; }
static inline struct hostent *gethostbyaddr(const void *addr, socklen_t len, int type) { return NULL; }
static inline struct hostent *gethostbyname2(const char *name, int af) { return NULL; }

#endif /* _NETDB_H */
