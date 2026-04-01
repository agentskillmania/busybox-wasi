/*
 * wsh_pipe.h — wsh 管道执行接口
 *
 * 串行管道：用 open_memstream / fmemopen 在内存中传递数据，
 * 不依赖 fork/pipe。
 */
#ifndef WSH_PIPE_H
#define WSH_PIPE_H

/**
 * 执行一条管道命令。
 *
 * @param cmdline  命令字符串，如 "echo hello | wc -c"
 * @return 最后一个命令的退出码（0-255）
 */
int wsh_run_pipeline(const char *cmdline);

#endif /* WSH_PIPE_H */
