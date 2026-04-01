/**
 * BusyBox WASM 构建 - setjmp.h 补丁
 *
 * wasi-libc 的 setjmp.h 要求 __wasm_exception_handling__ 宏（需要 -fwasm-exceptions），
 * 但 wasmtime 43 不支持 legacy EH 格式。本文件替代 wasi-libc 的 setjmp.h，
 * 提供 setjmp/longjmp 的声明，实现在 wasi_stubs.c 中。
 *
 * 注意：实为 stub。longjmp 会调用 _exit() 终止进程。
 * 对于不使用 setjmp 的 applet 无影响；使用 setjmp 的少数 applet
 * （bunzip2, gunzip）在错误恢复时会直接退出而非跳转。
 */
#ifndef _SETJMP_H
#define _SETJMP_H

#include <stddef.h>

/* jmp_buf：保存足够的寄存器状态 */
typedef struct {
	unsigned long __jb[8];
} jmp_buf[1];

#if __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 1)
#define __setjmp_attr __attribute__((__returns_twice__))
#else
#define __setjmp_attr
#endif

int setjmp(jmp_buf __env) __setjmp_attr;
_Noreturn void longjmp(jmp_buf __env, int __val);

#define setjmp setjmp

/* sigjmp_buf */
typedef jmp_buf sigjmp_buf;
int sigsetjmp(sigjmp_buf, int) __setjmp_attr;
_Noreturn void siglongjmp(sigjmp_buf, int);

#endif
