/*
 * wsh_pipe.c — wsh 串行管道执行
 *
 * 实现机制（WASI preview2 兼容）：
 *
 *   echo hello | cat | wc -c
 *
 *   所有段的 stdout 都通过 freopen 重定向到临时文件。
 *   上游输出写入临时文件 → 下游从临时文件读 stdin。
 *   最后一段的结果通过 write(2, ...) 输出到 stderr
 *   （stderr 始终指向终端，从未被重定向）。
 *
 * WASI 限制：
 *   - stdin/stdout 是 FILE *const → 用 freopen() 替换底层流
 *   - dup/dup2 不可用 → 用临时文件中转
 *   - 无法恢复 stdout 到终端 → 用 stderr 输出最终结果
 *
 * 不依赖 fork/pipe，完全串行执行。
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <setjmp.h>
#include <unistd.h>
#include "wsh_pipe.h"

/* ===================== BusyBox 外部符号 ===================== */

extern int find_applet_by_name(const char *name);
extern int (*const applet_main[])(int argc, char **argv);
extern const char *applet_name;
extern void (*die_func)(void);
extern unsigned char xfunc_error_retval;

/* ===================== 常量 ===================== */

/** 管道缓冲区最大 10MB */
#define WSH_PIPE_BUF_MAX (10 * 1024 * 1024)

/** 临时文件路径前缀 */
#define WSH_PIPE_PREFIX "/tmp/_wsh_p_"

/* ===================== setjmp 保护 ===================== */

static jmp_buf wsh_die_jmp;

static void wsh_die_jump(void)
{
	longjmp(wsh_die_jmp, xfunc_error_retval | 0x100);
}

/* ===================== 全局状态 save/restore ===================== */

struct wsh_save {
	const char *applet_name;
	void (*die_func)(void);
	unsigned char xfunc_error_retval;
};

static void wsh_save_state(struct wsh_save *s)
{
	s->applet_name = applet_name;
	s->die_func = die_func;
	s->xfunc_error_retval = xfunc_error_retval;
}

static void wsh_restore_state(struct wsh_save *s)
{
	applet_name = s->applet_name;
	die_func = s->die_func;
	xfunc_error_retval = s->xfunc_error_retval;
}

/* ===================== 分词 ===================== */

/**
 * 将命令字符串按空白分词，构建 argv 数组。
 *
 * @param cmd     命令字符串（会被修改）
 * @param tokens  输出 token 数组
 * @param max_t   数组容量
 * @return token 数量
 */
static int wsh_tokenize(char *cmd, char *tokens[], int max_t)
{
	int n = 0;
	char *sp;
	char *t = strtok_r(cmd, " \t", &sp);
	while (t && n < max_t - 1) {
		tokens[n++] = t;
		t = strtok_r(NULL, " \t", &sp);
	}
	tokens[n] = NULL;
	return n;
}

/* ===================== 单命令执行 ===================== */

/**
 * 执行单个 applet 命令（不做 I/O 重定向）。
 *
 * @param tokens  argv 数组
 * @param nargs   参数数量
 * @return 退出码 0-255
 */
static int wsh_exec(char *tokens[], int nargs)
{
	int no = find_applet_by_name(tokens[0]);
	if (no < 0) {
		fprintf(stderr, "wsh: %s: applet not found\n", tokens[0]);
		return 127;
	}

	struct wsh_save sv;
	wsh_save_state(&sv);

	xfunc_error_retval = 1;
	die_func = wsh_die_jump;

	int rc = setjmp(wsh_die_jmp);
	if (!rc) {
		applet_name = tokens[0];
		rc = applet_main[no](nargs, tokens);
		fflush(stdout);
	}

	wsh_restore_state(&sv);
	return rc & 0xff;
}

/* ===================== 管道拆分 ===================== */

/**
 * 按 | 拆分命令。
 *
 * @param cmd   完整命令字符串（会被修改）
 * @param segs  输出段数组
 * @param max   容量
 * @return 段数
 */
static int wsh_split_pipe(char *cmd, char *segs[], int max)
{
	int n = 0;
	char *sp;
	char *s = strtok_r(cmd, "|", &sp);
	while (s && n < max) {
		while (*s == ' ' || *s == '\t') s++;
		if (*s) segs[n++] = s;
		s = strtok_r(NULL, "|", &sp);
	}
	return n;
}

/* ===================== 临时文件工具 ===================== */

/** 生成管道临时文件路径 */
static void wsh_tmp_path(char *buf, size_t sz, int idx)
{
	snprintf(buf, sz, WSH_PIPE_PREFIX "%d", idx);
}

/**
 * 从文件读取全部内容到 malloc 缓冲区。
 *
 * @param path  文件路径
 * @param out   输出缓冲区指针（调用方 free）
 * @param olen  输出数据长度
 * @return 0 成功，-1 失败
 */
static int wsh_read_file(const char *path, char **out, size_t *olen)
{
	FILE *f = fopen(path, "r");
	if (!f) {
		*out = NULL;
		*olen = 0;
		return 0;
	}

	fseek(f, 0, SEEK_END);
	long sz = ftell(f);
	rewind(f);

	if (sz <= 0) {
		fclose(f);
		*out = NULL;
		*olen = 0;
		return 0;
	}

	if ((size_t)sz > WSH_PIPE_BUF_MAX) {
		fprintf(stderr, "wsh: pipe buffer exceeded %d bytes\n",
		        WSH_PIPE_BUF_MAX);
		sz = WSH_PIPE_BUF_MAX;
	}

	*out = malloc(sz);
	if (!*out) {
		fclose(f);
		return -1;
	}
	*olen = fread(*out, 1, sz, f);
	fclose(f);
	return 0;
}

/* ===================== 管道执行主函数 ===================== */

int wsh_run_pipeline(const char *cmdline)
{
	char *buf = strdup(cmdline);
	if (!buf) {
		fprintf(stderr, "wsh: out of memory\n");
		return 1;
	}

	/* 拆分管道段 */
	char *segs[64];
	int nseg = wsh_split_pipe(buf, segs, 64);
	if (nseg == 0) {
		fprintf(stderr, "wsh: empty command\n");
		free(buf);
		return 1;
	}

	/* 单命令（无管道）：直接执行 */
	if (nseg == 1) {
		char tmp[4096];
		strncpy(tmp, segs[0], sizeof(tmp) - 1);
		tmp[sizeof(tmp) - 1] = '\0';

		char *tok[256];
		int n = wsh_tokenize(tmp, tok, 256);
		free(buf);

		if (n == 0) {
			fprintf(stderr, "wsh: empty command\n");
			return 1;
		}
		return wsh_exec(tok, n);
	}

	/* ====== 多级管道：串行执行 ====== */
	int rc = 0;

	for (int i = 0; i < nseg; i++) {
		/* 复制当前段（分词会修改原串） */
		char cmd[4096];
		strncpy(cmd, segs[i], sizeof(cmd) - 1);
		cmd[sizeof(cmd) - 1] = '\0';

		char *tok[256];
		int n = wsh_tokenize(cmd, tok, 256);
		if (n == 0) {
			fprintf(stderr, "wsh: empty pipe segment\n");
			rc = 1;
			goto cleanup;
		}

		/*
		 * 设置 stdin：上游输出在上一次循环中已写入临时文件。
		 * 临时文件路径: WSH_PIPE_PREFIX + i-1
		 */
		if (i > 0) {
			char in_path[256];
			wsh_tmp_path(in_path, sizeof(in_path), i - 1);

			if (freopen(in_path, "r", stdin) == NULL) {
				fprintf(stderr, "wsh: cannot open pipe input\n");
				rc = 1;
				goto cleanup;
			}
		}

		/*
		 * 设置 stdout：所有段都重定向到临时文件。
		 * 最后一段的输出会在循环结束后通过 stderr 输出到终端。
		 */
		char out_path[256];
		wsh_tmp_path(out_path, sizeof(out_path), i);

		if (freopen(out_path, "w", stdout) == NULL) {
			fprintf(stderr, "wsh: cannot open pipe output\n");
			rc = 1;
			goto cleanup;
		}

		/* 执行命令 */
		rc = wsh_exec(tok, n);

		/*
		 * 上游 stdin 临时文件不再需要（已被当前段读完）。
		 * 删除以节省磁盘空间。
		 */
		if (i > 0) {
			char in_path[256];
			wsh_tmp_path(in_path, sizeof(in_path), i - 1);
			remove(in_path);
		}
	}

	/* ====== 输出最后一段的结果到终端 ====== */
	{
		char out_path[256];
		wsh_tmp_path(out_path, sizeof(out_path), nseg - 1);

		char *result = NULL;
		size_t rlen = 0;
		if (wsh_read_file(out_path, &result, &rlen) == 0 && result) {
			/*
			 * 用 write(2, ...) 写到 stderr。
			 * stderr 始终指向终端，从未被 freopen 重定向。
			 * 在 WASM sandbox 中 stdout 和 stderr
			 * 通常都指向同一个终端，用户看到的效果一样。
			 */
			write(STDERR_FILENO, result, rlen);
			free(result);
		}
		remove(out_path);
	}

cleanup:
	free(buf);
	return rc;
}
