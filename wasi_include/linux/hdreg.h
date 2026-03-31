#ifndef _LINUX_HDREG_H
#define _LINUX_HDREG_H

#include <linux/types.h>
#include <sys/ioctl.h>

/* 硬盘几何结构 */
struct hd_geometry {
	__u8 heads;
	__u8 sectors;
	__u16 cylinders;
	__u32 start;
};

#define HDIO_GETGEO     _IOR(0x03, 0x06, struct hd_geometry)
#define HDIO_GET_IDENTITY _IOR(0x03, 0x01, char[512])

#endif
