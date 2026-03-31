#ifndef _TERMIOS_H
#define _TERMIOS_H

#include <stddef.h>

typedef unsigned char cc_t;
typedef unsigned int speed_t;
typedef unsigned int tcflag_t;
#define NCCS 32
struct termios {
    tcflag_t c_iflag;
    tcflag_t c_oflag;
    tcflag_t c_cflag;
    tcflag_t c_lflag;
    cc_t c_cc[NCCS];
};

/* c_iflag 位掩码 */
#define IGNBRK  0x0001
#define BRKINT  0x0002
#define IGNPAR  0x0004
#define PARMRK  0x0008
#define INPCK   0x0010
#define ISTRIP  0x0020
#define INLCR   0x0040
#define IGNCR   0x0080
#define ICRNL   0x0100
#define IXON    0x0200
#define IXOFF   0x0400
#define IXANY   0x0800
#define IMAXBEL 0x1000

/* c_oflag 位掩码 */
#define OPOST   0x0001
#define ONLCR   0x0002
#define OCRNL   0x0004
#define ONOCR   0x0008
#define ONLRET  0x0010

/* c_cflag 位掩码 */
#define CSIZE   0x0030
#define CS5     0x0000
#define CS6     0x0010
#define CS7     0x0020
#define CS8     0x0030
#define CSTOPB  0x0040
#define CREAD   0x0080
#define PARENB  0x0100
#define PARODD  0x0200
#define HUPCL   0x0400
#define CLOCAL  0x0800
#define CRTSCTS 0x8000

/* c_lflag 位掩码 */
#define ISIG    0x0001
#define ICANON  0x0002
#define ECHO    0x0004
#define ECHOE   0x0008
#define ECHOK   0x0010
#define ECHONL  0x0020
#define NOFLSH  0x0040
#define TOSTOP  0x0100
#define ECHOCTL 0x0400
#define ECHOPRT 0x0800
#define ECHOKE  0x1000
#define FLUSHO  0x2000
#define PENDIN  0x4000
#define IEXTEN  0x8000

/* c_cc 索引 */
#define VINTR   0
#define VQUIT   1
#define VERASE  2
#define VKILL   3
#define VEOF    4
#define VTIME   5
#define VMIN    6
#define VSWTC   7
#define VSTART  8
#define VSTOP   9
#define VSUSP   10
#define VEOL    11
#define VREPRINT 12
#define VDISCARD 13
#define VWERASE 14
#define VLNEXT  15
#define VEOL2   16

/* tcsetattr 选项 */
#define TCSANOW   0
#define TCSADRAIN 1
#define TCSAFLUSH 2

/* tcflush 队列选择器 */
#define TCIFLUSH  0
#define TCOFLUSH  1
#define TCIOFLUSH 2

/* tcflow 动作 */
#define TCOOFF 0
#define TCOON  1
#define TCIOFF 2
#define TCION  3

/* XTABS - 旧式的制表符扩展 */
#define XTABS  0x0C00

/* winsize 结构体 — ioctl TIOCGWINSZ 使用 */
struct winsize {
    unsigned short ws_row;
    unsigned short ws_col;
    unsigned short ws_xpixel;
    unsigned short ws_ypixel;
};

/* winsize 相关 ioctl 码 */
#define TIOCGWINSZ 0x5413
#define TIOCSWINSZ 0x5414

/* ioctl 码 */
#define TCGETS  0x5401
#define TCSETS  0x5402

/* 波特率常量 */
#define B0      0
#define B50     1
#define B75     2
#define B110    3
#define B134    4
#define B150    5
#define B200    6
#define B300    7
#define B600    8
#define B1200   9
#define B1800   10
#define B2400   11
#define B4800   12
#define B9600   13
#define B19200  14
#define B38400  15
#define B57600  16
#define B115200 17

#ifdef __cplusplus
extern "C" {
#endif

static inline int tcgetattr(int fd, struct termios *t) { return -1; }
static inline int tcsetattr(int fd, int opt, const struct termios *t) { return -1; }
static inline speed_t cfgetispeed(const struct termios *t) { return 0; }
static inline speed_t cfgetospeed(const struct termios *t) { return 0; }
static inline int cfsetispeed(struct termios *t, speed_t s) { return -1; }
static inline int cfsetospeed(struct termios *t, speed_t s) { return -1; }
static inline int tcflush(int fd, int queue) { return -1; }
static inline int tcflow(int fd, int action) { return -1; }
static inline void cfmakeraw(struct termios *t) { }
static inline int tcsendbreak(int fd, int duration) { return -1; }

#ifdef __cplusplus
}
#endif

#endif /* _TERMIOS_H */
