cmd_libbb/hash_sha1_hwaccel_x86-64.o := /Users/yusangeng/wasi-sdk/bin/clang --target=wasm32-wasip1 --sysroot=/Users/yusangeng/wasi-sdk/share/wasi-sysroot -I/Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include -Wp,-MD,libbb/.hash_sha1_hwaccel_x86-64.o.d   -std=gnu99 -Iinclude -Ilibbb  -include include/autoconf.h -D_GNU_SOURCE -DNDEBUG -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_TIME_BITS=64 -DBB_VER='"1.37.0"'  -Wall -Wshadow -Wwrite-strings -Wundef -Wstrict-prototypes -Wunused -Wunused-parameter -Wunused-function -Wunused-value -Wmissing-prototypes -Wmissing-declarations -Wno-format-security -Wdeclaration-after-statement -Wold-style-definition -finline-limit=0 -fno-builtin-strlen -fomit-frame-pointer -ffunction-sections -fdata-sections  -funsigned-char -static-libgcc -falign-functions=1 -falign-jumps=1 -falign-labels=1 -falign-loops=1 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-builtin-printf -Oz -I/Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_PROCESS_CLOCKS -fwasm-exceptions -Wno-implicit-function-declaration -Wno-int-conversion -Wno-unknown-attributes -DSOCK_RDM=4 -DSOCK_SEQPACKET=5 -DSOCK_RAW=3 -DSOCK_DCCP=6 -DPRIO_PROCESS=0 -DPRIO_PGRP=1 -DPRIO_USER=2 -DF_GETLK=5 -DF_SETLK=6 -DF_SETLKW=7 -DF_RDLCK=0 -DF_WRLCK=1 -DF_UNLCK=2 -DO_NDELAY=0x800 -D__linux__ -DF_DUPFD=0       -c -o libbb/hash_sha1_hwaccel_x86-64.o libbb/hash_sha1_hwaccel_x86-64.S

deps_libbb/hash_sha1_hwaccel_x86-64.o := \
  libbb/hash_sha1_hwaccel_x86-64.S \
    $(wildcard include/config/sha1/hwaccel.h) \

libbb/hash_sha1_hwaccel_x86-64.o: $(deps_libbb/hash_sha1_hwaccel_x86-64.o)

$(deps_libbb/hash_sha1_hwaccel_x86-64.o):
