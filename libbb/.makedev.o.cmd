cmd_libbb/makedev.o := /Users/yusangeng/wasi-sdk/bin/clang --target=wasm32-wasip1 --sysroot=/Users/yusangeng/wasi-sdk/share/wasi-sysroot -I/Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include -Wp,-MD,libbb/.makedev.o.d   -std=gnu99 -Iinclude -Ilibbb  -include include/autoconf.h -D_GNU_SOURCE -DNDEBUG -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_TIME_BITS=64 -DBB_VER='"1.37.0"'  -Wall -Wshadow -Wwrite-strings -Wundef -Wstrict-prototypes -Wunused -Wunused-parameter -Wunused-function -Wunused-value -Wmissing-prototypes -Wmissing-declarations -Wno-format-security -Wdeclaration-after-statement -Wold-style-definition -finline-limit=0 -fno-builtin-strlen -fomit-frame-pointer -ffunction-sections -fdata-sections  -funsigned-char -static-libgcc -falign-functions=1 -falign-jumps=1 -falign-labels=1 -falign-loops=1 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-builtin-printf -Oz -I/Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_PROCESS_CLOCKS -fwasm-exceptions -Wno-implicit-function-declaration -Wno-int-conversion -Wno-unknown-attributes -DSOCK_RDM=4 -DSOCK_SEQPACKET=5 -DSOCK_RAW=3 -DSOCK_DCCP=6 -DPRIO_PROCESS=0 -DPRIO_PGRP=1 -DPRIO_USER=2 -DF_GETLK=5 -DF_SETLK=6 -DF_SETLKW=7 -DF_RDLCK=0 -DF_WRLCK=1 -DF_UNLCK=2 -DO_NDELAY=0x800 -D__linux__ -DF_DUPFD=0    -DKBUILD_BASENAME='"makedev"'  -DKBUILD_MODNAME='"makedev"' -c -o libbb/makedev.o libbb/makedev.c

deps_libbb/makedev.o := \
  libbb/makedev.c \
  include/platform.h \
    $(wildcard include/config/werror.h) \
    $(wildcard include/config/big/endian.h) \
    $(wildcard include/config/little/endian.h) \
    $(wildcard include/config/nommu.h) \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/limits.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/limits.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/features.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/alltypes.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_timeval.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_suseconds_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_time_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_timespec.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_iovec.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/stddef.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stddef_size_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/limits.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__macro_PAGESIZE.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/byteswap.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/stdint.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdint.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/stdint.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/endian.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/stdbool.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdbool.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/unistd.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_unistd.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__seek.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/inttypes.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/inttypes.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_inttypes.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stddef_wchar_t.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stddef_null.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/posix.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/sys/sysmacros.h \

libbb/makedev.o: $(deps_libbb/makedev.o)

$(deps_libbb/makedev.o):
