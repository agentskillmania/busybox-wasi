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

/** Redirection info for a pre-parsed pipeline segment */
struct wsh_seg_redir {
	char *out_path;    /* stdout target (>, >>), NULL = none */
	int   out_append;  /* 1=append, 0=overwrite */
	char *in_path;     /* stdin source (<), NULL = none */
	char *err_path;    /* stderr target (2>), NULL = none */
};

/** A single pipeline segment with pre-built argv */
struct wsh_pipeline_seg {
	char **argv;
	int    argc;
	struct wsh_seg_redir redir;
};

/**
 * Execute a pipeline with pre-built segments.
 * Each segment has its own expanded argv and parsed redirections.
 */
int wsh_run_pipeline_segs(struct wsh_pipeline_seg *segs, int nseg);

/** Free resources in a redirection struct */
void wsh_seg_redir_free(struct wsh_seg_redir *r);

/**
 * Parse redirection operators from argv, removing redir tokens in-place.
 * Supports: >, >>, <, 2>, 2>>
 * Returns new argc after removing redir tokens.
 */
int wsh_parse_redir_tokens(char *tokens[], int nargs,
			   struct wsh_seg_redir *redir);

/**
 * 执行命令并捕获 stdout 输出。
 * 用于命令替换 $()。
 *
 * 实现：freopen(stdout→临时文件) → 执行 → 读临时文件 → 去尾换行。
 *
 * @param cmdline  命令字符串
 * @return 捕获的输出（malloc，调用方 free），失败返回 strdup("")
 */
char *wsh_capture_output(const char *cmdline);

#endif /* WSH_PIPE_H */
