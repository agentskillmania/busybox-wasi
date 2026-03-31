cmd_libbb/human_readable.o := /Users/yusangeng/wasi-sdk/bin/clang --target=wasm32-wasip1 --sysroot=/Users/yusangeng/wasi-sdk/share/wasi-sysroot -I/Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include -Wp,-MD,libbb/.human_readable.o.d   -std=gnu99 -Iinclude -Ilibbb  -include include/autoconf.h -D_GNU_SOURCE -DNDEBUG -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_TIME_BITS=64 -DBB_VER='"1.37.0"'  -Wall -Wshadow -Wwrite-strings -Wundef -Wstrict-prototypes -Wunused -Wunused-parameter -Wunused-function -Wunused-value -Wmissing-prototypes -Wmissing-declarations -Wno-format-security -Wdeclaration-after-statement -Wold-style-definition -finline-limit=0 -fno-builtin-strlen -fomit-frame-pointer -ffunction-sections -fdata-sections  -funsigned-char -static-libgcc -falign-functions=1 -falign-jumps=1 -falign-labels=1 -falign-loops=1 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-builtin-printf -Oz -I/Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_PROCESS_CLOCKS -fwasm-exceptions -Wno-implicit-function-declaration -Wno-int-conversion -Wno-unknown-attributes -DSOCK_RDM=4 -DSOCK_SEQPACKET=5 -DSOCK_RAW=3 -DSOCK_DCCP=6 -DPRIO_PROCESS=0 -DPRIO_PGRP=1 -DPRIO_USER=2 -DF_GETLK=5 -DF_SETLK=6 -DF_SETLKW=7 -DF_RDLCK=0 -DF_WRLCK=1 -DF_UNLCK=2 -DO_NDELAY=0x800 -D__linux__ -DF_DUPFD=0    -DKBUILD_BASENAME='"human_readable"'  -DKBUILD_MODNAME='"human_readable"' -c -o libbb/human_readable.o libbb/human_readable.c

deps_libbb/human_readable.o := \
  libbb/human_readable.c \
  include/libbb.h \
    $(wildcard include/config/feature/shadowpasswds.h) \
    $(wildcard include/config/use/bb/shadow.h) \
    $(wildcard include/config/selinux.h) \
    $(wildcard include/config/feature/utmp.h) \
    $(wildcard include/config/locale/support.h) \
    $(wildcard include/config/use/bb/pwd/grp.h) \
    $(wildcard include/config/lfs.h) \
    $(wildcard include/config/feature/buffers/go/on/stack.h) \
    $(wildcard include/config/feature/buffers/go/in/bss.h) \
    $(wildcard include/config/extra/cflags.h) \
    $(wildcard include/config/variable/arch/pagesize.h) \
    $(wildcard include/config/feature/verbose.h) \
    $(wildcard include/config/feature/etc/services.h) \
    $(wildcard include/config/feature/ipv6.h) \
    $(wildcard include/config/feature/seamless/xz.h) \
    $(wildcard include/config/feature/seamless/lzma.h) \
    $(wildcard include/config/feature/seamless/bz2.h) \
    $(wildcard include/config/feature/seamless/gz.h) \
    $(wildcard include/config/feature/seamless/z.h) \
    $(wildcard include/config/float/duration.h) \
    $(wildcard include/config/feature/check/names.h) \
    $(wildcard include/config/feature/prefer/applets.h) \
    $(wildcard include/config/long/opts.h) \
    $(wildcard include/config/feature/pidfile.h) \
    $(wildcard include/config/feature/syslog.h) \
    $(wildcard include/config/feature/syslog/info.h) \
    $(wildcard include/config/warn/simple/msg.h) \
    $(wildcard include/config/feature/individual.h) \
    $(wildcard include/config/shell/ash.h) \
    $(wildcard include/config/shell/hush.h) \
    $(wildcard include/config/echo.h) \
    $(wildcard include/config/sleep.h) \
    $(wildcard include/config/ash/sleep.h) \
    $(wildcard include/config/printf.h) \
    $(wildcard include/config/test.h) \
    $(wildcard include/config/test1.h) \
    $(wildcard include/config/test2.h) \
    $(wildcard include/config/kill.h) \
    $(wildcard include/config/killall.h) \
    $(wildcard include/config/killall5.h) \
    $(wildcard include/config/chown.h) \
    $(wildcard include/config/ls.h) \
    $(wildcard include/config/xxx.h) \
    $(wildcard include/config/route.h) \
    $(wildcard include/config/feature/hwib.h) \
    $(wildcard include/config/desktop.h) \
    $(wildcard include/config/feature/crond/d.h) \
    $(wildcard include/config/feature/setpriv/capabilities.h) \
    $(wildcard include/config/run/init.h) \
    $(wildcard include/config/feature/securetty.h) \
    $(wildcard include/config/pam.h) \
    $(wildcard include/config/use/bb/crypt.h) \
    $(wildcard include/config/feature/adduser/to/group.h) \
    $(wildcard include/config/feature/del/user/from/group.h) \
    $(wildcard include/config/ioctl/hex2str/error.h) \
    $(wildcard include/config/feature/editing.h) \
    $(wildcard include/config/feature/editing/history.h) \
    $(wildcard include/config/feature/tab/completion.h) \
    $(wildcard include/config/feature/username/completion.h) \
    $(wildcard include/config/feature/editing/fancy/prompt.h) \
    $(wildcard include/config/feature/editing/savehistory.h) \
    $(wildcard include/config/feature/editing/vi.h) \
    $(wildcard include/config/feature/editing/save/on/exit.h) \
    $(wildcard include/config/pmap.h) \
    $(wildcard include/config/feature/show/threads.h) \
    $(wildcard include/config/feature/ps/additional/columns.h) \
    $(wildcard include/config/feature/topmem.h) \
    $(wildcard include/config/feature/top/smp/process.h) \
    $(wildcard include/config/pgrep.h) \
    $(wildcard include/config/pkill.h) \
    $(wildcard include/config/pidof.h) \
    $(wildcard include/config/sestatus.h) \
    $(wildcard include/config/unicode/support.h) \
    $(wildcard include/config/feature/mtab/support.h) \
    $(wildcard include/config/feature/clean/up.h) \
    $(wildcard include/config/feature/devfs.h) \
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
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/ctype.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/dirent.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_dirent.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_dirent.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_ino_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_DIR.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/dirent.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/errno.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__errno.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__errno_values.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/fcntl.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_fcntl.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__mode_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/fcntl.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/netdb.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/socket.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/wasi/version.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_sys_socket.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_msghdr.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_socklen_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_sockaddr.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_sa_family_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_sockaddr_storage.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/wasi/api.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/wasi/wasip1.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stddef_header_macro.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stddef_ptrdiff_t.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stddef_offsetof.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/types.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_clockid_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_clock_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/select.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_sigset_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__fd_set.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_fd_set.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__macro_FD_SETSIZE.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/socket.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/setjmp.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/setjmp.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/signal.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/signal.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/paths.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdio.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdlib.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__functions_malloc.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_stdlib.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/alloca.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/stdarg.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stdarg_header_macro.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stdarg___gnuc_va_list.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stdarg_va_list.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stdarg_va_arg.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stdarg___va_copy.h \
  /Users/yusangeng/wasi-sdk/lib/clang/22/include/__stdarg_va_copy.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/string.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_string.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__functions_memcpy.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/strings.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/libgen.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/poll.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/sys/poll.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/sys/ioctl.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/mman.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/mman.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/resource.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/time.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/resource.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_sys_resource.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_rusage.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/sys/stat.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/stat.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/stat.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_stat.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_blkcnt_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_blksize_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_dev_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_gid_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_mode_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_nlink_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_off_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_uid_t.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_sys_stat.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/sys/sysmacros.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/sys/wait.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/termios.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/time.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_time.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_tm.h \
  /Users/yusangeng/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/param.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/pwd.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/grp.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/mntent.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/sys/statfs.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/utmp.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/utmpx.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/arpa/inet.h \
  /Users/yusangeng/Downloads/busybox-1.37.0-wasm-build/wasi_include/netinet/in.h \
  include/pwd_.h \
  include/grp_.h \
  include/shadow_.h \
  include/xatonum.h \

libbb/human_readable.o: $(deps_libbb/human_readable.o)

$(deps_libbb/human_readable.o):
