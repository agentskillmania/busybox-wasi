#ifndef _SYS_IOCTL_H
#define _SYS_IOCTL_H

/* ioctl 宏定义 */
#define _IOC_NRBITS     8
#define _IOC_TYPEBITS   8
#define _IOC_SIZEBITS   14
#define _IOC_DIRBITS    2

#define _IOC_NONE       0U
#define _IOC_WRITE      1U
#define _IOC_READ       2U

#define _IOC(dir, type, nr, size) \
    (((dir)  << _IOC_DIRBITS) | \
     ((type) << _IOC_TYPEBITS) | \
     ((nr)   << _IOC_NRBITS) | \
     ((size) << (_IOC_NRBITS + _IOC_TYPEBITS)))

#define _IO(type, nr)          _IOC(_IOC_NONE, (type), (nr), 0)
#define _IOW(type, nr, size)   _IOC(_IOC_WRITE, (type), (nr), sizeof(size))
#define _IOR(type, nr, size)   _IOC(_IOC_READ, (type), (nr), sizeof(size))
#define _IOWR(type, nr, size)  _IOC(_IOC_READ|_IOC_WRITE, (type), (nr), sizeof(size))

/* 终端 ioctl 常量 */
#define TIOCSCTTY   0x540E
#define TIOCNOTTY   0x5422
#define TIOCGWINSZ  0x5413
#define TIOCSWINSZ  0x5414
#define TIOCGPGRP   0x540F
#define TIOCSPGRP   0x5410
#define FIONREAD    0x541B
#define FIONBIO     0x5421
#define TCGETS      0x5401
#define TCSETS      0x5402

#ifdef __cplusplus
extern "C" {
#endif

static inline int ioctl(int fd, unsigned long req, ...) { return -1; }

#ifdef __cplusplus
}
#endif

#endif
