#ifndef _LINUX_FD_H
#define _LINUX_FD_H

#include <linux/types.h>
#include <sys/ioctl.h>

/* 软盘参数结构 */
struct floppy_struct {
	unsigned int size;
	unsigned int sect;
	unsigned int head;
	unsigned int track;
	unsigned int stretch;
	unsigned char gap;
	unsigned char rate;
	unsigned char spec1;
	unsigned char fmt_gap;
	const char *name;
};

#define FDGETPRM _IOR(2, 0x04, struct floppy_struct)

#endif
