#ifndef _PWD_H
#define _PWD_H
struct passwd { char *pw_name; char *pw_passwd; unsigned int pw_uid; unsigned int pw_gid; char *pw_gecos; char *pw_dir; char *pw_shell; };
struct group { char *gr_name; char *gr_passwd; unsigned int gr_gid; char **gr_mem; };
static inline struct passwd *getpwuid(unsigned int u) { return NULL; }
static inline struct passwd *getpwnam(const char *n) { return NULL; }
static inline struct group *getgrgid(unsigned int g) { return NULL; }
static inline struct group *getgrnam(const char *n) { return NULL; }
static inline void endpwent(void) {}
static inline void endgrent(void) {}
static inline struct passwd *getpwent(void) { return NULL; }
static inline struct group *getgrent(void) { return NULL; }
static inline void setpwent(void) {}
static inline void setgrent(void) {}
static inline int initgroups(const char *u, unsigned int g) { return -1; }
static inline struct passwd *fgetpwent(FILE *f) { return NULL; }
static inline struct group *fgetgrent(FILE *f) { return NULL; }
static inline int putpwent(const struct passwd *p, FILE *f) { return -1; }
#endif
