# arch/wasm32/Makefile — WASM/WASI 构建配置
#
# 用法: make ARCH=wasm32 WASI_SDK=$HOME/wasi-sdk SKIP_STRIP=y -j$(nproc)
#
# Kbuild 在 Makefile:504 通过 -include arch/$(ARCH)/Makefile 加载此文件。
# 设置 CC/AR/LD/NM/STRIP 和 WASM 特有的编译/链接标志。

ifdef WASI_SDK

WASI_SYSROOT := $(WASI_SDK)/share/wasi-sysroot

# 工具链覆盖
CC    = $(WASI_SDK)/bin/wasm32-wasip2-clang --sysroot=$(WASI_SYSROOT)
AR    = $(WASI_SDK)/bin/llvm-ar
LD    = $(srctree)/wasm-ld-wrapper.sh
NM    = $(WASI_SDK)/bin/llvm-nm
STRIP = true

# 头文件和兼容性补丁
CPPFLAGS += -I$(srctree)/wasi_include -include $(srctree)/wasi/wasi_compat.h

# SjLj 异常处理（wasi-preview2 需要此选项支持 setjmp/longjmp）
CPPFLAGS += -mllvm -wasm-enable-sjlj -mllvm -wasm-use-legacy-eh=0

# WASI 平台补丁定义
# 启用 wasi-libc 的兼容层（信号、mman、进程时钟、getpid）
CPPFLAGS += -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_MMAN
CPPFLAGS += -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID
# POSIX 常量补丁（wasi-libc 头文件缺失的定义）
CPPFLAGS += -DSOCK_RDM=4 -DSOCK_SEQPACKET=5 -DSOCK_RAW=3 -DSOCK_DCCP=6
CPPFLAGS += -DPRIO_PROCESS=0 -DPRIO_PGRP=1 -DPRIO_USER=2
CPPFLAGS += -DF_GETLK=5 -DF_SETLK=6 -DF_SETLKW=7
CPPFLAGS += -DF_RDLCK=0 -DF_WRLCK=1 -DF_UNLCK=2
CPPFLAGS += -DO_NDELAY=0x800 -DF_DUPFD=0
# 禁用 wasi-libc 中与 Linux 不兼容的定义
CPPFLAGS += -UIP_PKTINFO -UIPV6_PKTINFO

# -Wno- 警告关闭标志不能放在这里（Makefile.flags 会覆盖 CFLAGS）。
# 这些标志通过 CONFIG_EXTRA_CFLAGS 追加，在 Makefile.flags 之后生效。

# 链接标志
# --error-limit=0 显示所有链接错误
# --wrap=open/read/close 拦截 /dev/urandom 访问，重定向到 wasi:random
LDFLAGS += -Wl,--error-limit=0
LDFLAGS += -Wl,--wrap=open -Wl,--wrap=read -Wl,--wrap=write -Wl,--wrap=close

endif # WASI_SDK
