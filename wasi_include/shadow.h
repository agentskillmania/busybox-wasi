#ifndef _SHADOW_H
#define _SHADOW_H
struct spwd { char *sp_namp, *sp_pwdp; long sp_lstchg, sp_min, sp_max, sp_warn, sp_inact, sp_expire; unsigned long sp_flag; };
static inline struct spwd *getspnam(const char *n) { return NULL; }
static inline void endspent(void) {}
#endif
