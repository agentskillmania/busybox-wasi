/* Stub sys/sysmacros.h for WASI */
#ifndef _SYS_SYSMACROS_H
#define _SYS_SYSMACROS_H

static inline unsigned int major(unsigned int dev) { return (dev >> 8) & 0xfff; }
static inline unsigned int minor(unsigned int dev) { return dev & 0xff; }
static inline unsigned int makedev(unsigned int maj, unsigned int min) { return (maj << 8) | min; }

#endif
