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
CPPFLAGS += -I$(srctree)/wasi_include -include $(srctree)/wasi_compat.h

# SjLj 异常处理（wasi-preview2 需要此选项支持 setjmp/longjmp）
CPPFLAGS += -mllvm -wasm-enable-sjlj -mllvm -wasm-use-legacy-eh=0

# 关闭不影响质量的编译警告
# 注意：此文件在 Makefile.flags 之前被 include，CFLAGS 会被 Makefile.flags 覆盖。
# 因此 -Wno- 标志通过 CONFIG_EXTRA_CFLAGS 追加（在 Makefile.flags 之后生效）。

# 链接标志：--allow-undefined 容忍未解析符号（wasi 组件模型限制）
# --error-limit=0 显示所有链接错误
LDFLAGS += -Wl,--allow-undefined -Wl,--error-limit=0

endif # WASI_SDK
