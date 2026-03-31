#ifndef _SYS_REBOOT_H
#define _SYS_REBOOT_H
#define RB_AUTOBOOT     0x01234567
#define RB_HALT_SYSTEM  0xcdef0123
#define RB_ENABLE_CAD   0x89abcdef
#define RB_DISABLE_CAD  0
#define RB_POWER_OFF    0x4321fedc
#define RB_HALT         RB_HALT_SYSTEM
static inline int reboot(int f) { return -1; }
#endif
