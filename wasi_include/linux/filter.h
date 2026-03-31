#ifndef _LINUX_FILTER_H
#define _LINUX_FILTER_H

struct sock_filter {
    unsigned short code;
    unsigned char jt;
    unsigned char jf;
    unsigned int k;
};

struct sock_fprog {
    unsigned short len;
    struct sock_filter *filter;
};

#define BPF_RET  0x06
#define BPF_JA   0x00
#define BPF_LD   0x00
#define BPF_W    0x00
#define BPF_ABS  0x20
#define BPF_ALU  0x04
#define BPF_AND  0x50
#define BPF_JMP  0x05
#define BPF_JEQ  0x10
#define BPF_K    0x00

#define SKF_AD_OFF    (-0x1000)
#define SKF_AD_PROTOCOL (-0x1000)
#define SKF_AD_PKTTYPE (-0x1001)
#define SKF_AD_IFINDEX (-0x1002)

#endif
