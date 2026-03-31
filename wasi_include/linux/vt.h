#ifndef _LINUX_VT_H
#define _LINUX_VT_H
#define VT_GETMODE 0x5601
#define VT_SETMODE 0x5602
#define VT_ACTIVATE 0x5606
#define VT_WAITACTIVE 0x5607
struct vt_mode { int mode; short waitv; short relsig; short acqsig; short frsig; };
#endif
