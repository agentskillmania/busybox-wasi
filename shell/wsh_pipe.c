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

/* ===================== Glob 展开 ===================== */

#include <dirent.h>

/**
 * 检查字符串是否含通配符字符（*, ?, [）。
 */
static int wsh_has_glob(const char *s)
{
	for (; *s; s++) {
		if (*s == '*' || *s == '?' || *s == '[')
			return 1;
	}
	return 0;
}

/**
 * 简单通配符匹配：支持 * 和 ? 。
 * pattern 中的 * 匹配任意字符串，? 匹配单个字符。
 */
static int wsh_glob_match(const char *pat, const char *str)
{
	while (*pat && *str) {
		if (*pat == '*') {
			pat++;
			/* * 匹配零个或多个字符 */
			if (!*pat) return 1;
			while (*str) {
				if (wsh_glob_match(pat, str))
					return 1;
				str++;
			}
			return wsh_glob_match(pat, str);
		}
		if (*pat == '?') {
			pat++; str++;
			continue;
		}
		if (*pat != *str)
			return 0;
		pat++; str++;
	}
	/* 剩余 pat 中只有 * 可以匹配空串 */
	while (*pat == '*') pat++;
	return *pat == '\0' && *str == '\0';
}

/**
 * 对单个含通配符的路径做展开。
 *
 * 从路径中提取目录部分和文件名模式，
 * 扫描目录匹配文件，返回匹配的完整路径。
 *
 * @param token    含通配符的路径（如 "/tmp/wsh_*.txt"）
 * @param out      输出字符串数组
 * @param max_out  数组容量
 * @param pnout    输入当前数量 / 输出增加后的数量
 * @return 0 成功，-1 失败
 */
static int wsh_glob_one(const char *token, char *out[], int max_out, int *pnout)
{
	/* 分离目录和文件名部分（堆分配避免栈溢出） */
	char *dir = malloc(512);
	char *full = malloc(512);
	if (!dir || !full) { free(dir); free(full); return -1; }

	const char *base;
	const char *slash = strrchr(token, '/');
	if (slash) {
		int dlen = (int)(slash - token);
		if (dlen == 0) {
			dir[0] = '/'; dir[1] = '\0';
		} else {
			memcpy(dir, token, dlen);
			dir[dlen] = '\0';
		}
		base = slash + 1;
	} else {
		dir[0] = '.'; dir[1] = '\0';
		base = token;
	}

	if (!*base) { free(dir); free(full); return -1; }

	DIR *dp = opendir(dir);
	if (!dp) { free(dir); free(full); return -1; }

	struct dirent *de;
	while ((de = readdir(dp)) != NULL) {
		if (de->d_name[0] == '.' && base[0] != '.')
			continue;
		if (!wsh_glob_match(base, de->d_name))
			continue;

		if (*pnout >= max_out - 1) break;

		/* 构造完整路径 */
		if (strcmp(dir, ".") == 0)
			snprintf(full, 512, "%s", de->d_name);
		else if (strcmp(dir, "/") == 0)
			snprintf(full, 512, "/%s", de->d_name);
		else
			snprintf(full, 512, "%s/%s", dir, de->d_name);
		out[(*pnout)++] = strdup(full);
	}
	closedir(dp);
	free(dir);
	free(full);
	return 0;
}

/**
 * 对 token 数组做 glob 展开。
 *
 * 含通配符的 token 替换为匹配文件列表；
 * 无通配符或无匹配的 token 保持原样。
 */
static int wsh_glob_expand(char *tokens[], int nargs, int max_t)
{
	/* 堆分配避免栈溢出 */
	char **out = malloc(max_t * sizeof(char *));
	if (!out) return nargs;

	int nout = 0;

	for (int i = 0; i < nargs && nout < max_t - 1; i++) {
		if (!wsh_has_glob(tokens[i])) {
			out[nout++] = tokens[i];
			continue;
		}

		int before = nout;
		wsh_glob_one(tokens[i], out, max_t, &nout);

		if (nout == before) {
			/* 无匹配：保留原始 token */
			out[nout++] = tokens[i];
		}
	}

	for (int i = 0; i < nout; i++)
		tokens[i] = out[i];
	tokens[nout] = NULL;

	free(out);
	return nout;
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

/* ===================== 重定向解析 ===================== */

/** 重定向信息 */
struct wsh_redir {
	char *out_path;   /* stdout 目标（> 或 >>），NULL 表示无 */
	int  out_append;  /* 1=追加(>>)，0=覆盖(>) */
	char *in_path;    /* stdin 来源（<），NULL 表示无 */
	char *err_path;   /* stderr 目标（2>），NULL 表示无 */
};

/**
 * 从命令字符串中解析重定向操作符，返回去掉重定向部分的新字符串。
 * 同时填充 redir 结构体。
 *
 * 支持: >, >>, <, 2>
 * 引号内的 > < 不视为重定向。
 *
 * @param cmd    原始命令字符串
 * @param redir  输出重定向信息（路径都是 malloc，调用方 free）
 * @return       清理后的命令字符串（malloc，调用方 free）
 */
static char *wsh_parse_redir(const char *cmd, struct wsh_redir *redir)
{
	redir->out_path = NULL;
	redir->out_append = 0;
	redir->in_path = NULL;
	redir->err_path = NULL;

	size_t len = strlen(cmd);
	char *clean = malloc(len + 1);
	int ci = 0; /* clean 写入位置 */
	int in_sq = 0, in_dq = 0;

	/* 跳过前导空白后的 word 可能是重定向目标，
	 * 我们从右向左扫描，但简化起见从左向右处理。
	 * 遇到未引号包裹的 >, >>, <, 2> 时提取文件路径。 */
	int i = 0;
	while (i < (int)len) {
		/* 引号跟踪 */
		if (!in_dq && cmd[i] == '\'') { in_sq = !in_sq; clean[ci++] = cmd[i++]; continue; }
		if (!in_sq && cmd[i] == '"')  { in_dq = !in_dq; clean[ci++] = cmd[i++]; continue; }
		if (in_sq || in_dq) { clean[ci++] = cmd[i++]; continue; }

		/* 2> 或 2>> */
		if (cmd[i] == '2' && i + 1 < (int)len && cmd[i + 1] == '>') {
			/* 跳过 "2" 不写入 clean */
			int j = i + 2;
			int append = 0;
			if (j < (int)len && cmd[j] == '>') { append = 1; j++; }
			while (j < (int)len && (cmd[j] == ' ' || cmd[j] == '\t')) j++;
			int s = j;
			while (j < (int)len && cmd[j] != ' ' && cmd[j] != '\t' &&
			       cmd[j] != ';' && cmd[j] != '|' && cmd[j] != '>' &&
			       cmd[j] != '<')
				j++;
			if (j > s) {
				redir->err_path = malloc(j - s + 1);
				memcpy(redir->err_path, cmd + s, j - s);
				redir->err_path[j - s] = '\0';
				redir->out_append = append; /* 复用，2>> 时为追加 */
			}
			i = j;
			/* 跳过后导空白 */
			while (i < (int)len && (cmd[i] == ' ' || cmd[i] == '\t')) i++;
			continue;
		}

		/* >> 或 > (非 2>) */
		if (cmd[i] == '>') {
			int j = i;
			int append = 0;
			j++;
			if (j < (int)len && cmd[j] == '>') { append = 1; j++; }
			while (j < (int)len && (cmd[j] == ' ' || cmd[j] == '\t')) j++;
			int s = j;
			while (j < (int)len && cmd[j] != ' ' && cmd[j] != '\t' &&
			       cmd[j] != ';' && cmd[j] != '|' && cmd[j] != '>' &&
			       cmd[j] != '<')
				j++;
			if (j > s) {
				free(redir->out_path); /* 取最后一个 */
				redir->out_path = malloc(j - s + 1);
				memcpy(redir->out_path, cmd + s, j - s);
				redir->out_path[j - s] = '\0';
				redir->out_append = append;
			}
			i = j;
			while (i < (int)len && (cmd[i] == ' ' || cmd[i] == '\t')) i++;
			continue;
		}

		/* < */
		if (cmd[i] == '<') {
			int j = i + 1;
			while (j < (int)len && (cmd[j] == ' ' || cmd[j] == '\t')) j++;
			int s = j;
			while (j < (int)len && cmd[j] != ' ' && cmd[j] != '\t' &&
			       cmd[j] != ';' && cmd[j] != '|' && cmd[j] != '>' &&
			       cmd[j] != '<')
				j++;
			if (j > s) {
				free(redir->in_path);
				redir->in_path = malloc(j - s + 1);
				memcpy(redir->in_path, cmd + s, j - s);
				redir->in_path[j - s] = '\0';
			}
			i = j;
			while (i < (int)len && (cmd[i] == ' ' || cmd[i] == '\t')) i++;
			continue;
		}

		clean[ci++] = cmd[i++];
	}
	clean[ci] = '\0';
	return clean;
}

/** 释放 redir 中的动态分配 */
static void wsh_redir_free(struct wsh_redir *r)
{
	free(r->out_path);
	free(r->in_path);
	free(r->err_path);
	r->out_path = r->in_path = r->err_path = NULL;
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

	/*
	 * 单命令（无管道）：也走临时文件 + stderr 输出。
	 * 统一架构：命令替换 $() 后 stdout 可能指向 sub 临时文件，
	 * freopen 会覆盖到新的 pipe 临时文件，最终通过 stderr 输出到终端。
	 */
	if (nseg == 1) {
		/* 解析重定向 */
		struct wsh_redir redir;
		char *clean = wsh_parse_redir(segs[0], &redir);
		free(buf);

		char cmd[4096];
		strncpy(cmd, clean, sizeof(cmd) - 1);
		cmd[sizeof(cmd) - 1] = '\0';
		free(clean);

		char *tok[256];
		int n = wsh_tokenize(cmd, tok, 256);
		n = wsh_glob_expand(tok, n, 256);

		if (n == 0) {
			fprintf(stderr, "wsh: empty command\n");
			wsh_redir_free(&redir);
			return 1;
		}

		/* 输入重定向 */
		if (redir.in_path) {
			freopen(redir.in_path, "r", stdin);
		}

		/* 输出重定向：有重定向则写到目标文件，否则走临时文件 */
		int redirected_out = (redir.out_path != NULL);
		char out_path[256];
		if (redirected_out) {
			freopen(redir.out_path, redir.out_append ? "a" : "w", stdout);
		} else {
			wsh_tmp_path(out_path, sizeof(out_path), 0);
			if (freopen(out_path, "w", stdout) == NULL) {
				fprintf(stderr, "wsh: cannot open pipe output\n");
				wsh_redir_free(&redir);
				return 1;
			}
		}

		if (redir.err_path) {
			freopen(redir.err_path, "w", stderr);
		}

		int rc = wsh_exec(tok, n);
		fflush(stdout);

		if (!redirected_out) {
			/* 读临时文件 → 输出到 stderr（终端） */
			char *result = NULL;
			size_t rlen = 0;
			if (wsh_read_file(out_path, &result, &rlen) == 0 && result) {
				write(STDERR_FILENO, result, rlen);
				free(result);
			}
			remove(out_path);
		}
		wsh_redir_free(&redir);
		return rc;
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
		n = wsh_glob_expand(tok, n, 256);
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

/* ===================== 命令输出捕获 ===================== */

/** 命令捕获临时文件前缀 */
#define WSH_CAP_PREFIX "/tmp/_wsh_cap_"

/** 捕获计数器 */
static int g_cap_counter;

char *wsh_capture_output(const char *cmdline)
{
	char tmp_path[256];
	snprintf(tmp_path, sizeof(tmp_path),
	         WSH_CAP_PREFIX "%d", g_cap_counter++);

	/* 重定向 stdout 到临时文件 */
	if (freopen(tmp_path, "w", stdout) == NULL)
		return strdup("");

	int rc = wsh_run_pipeline(cmdline);
	fflush(stdout);
	(void)rc;

	/* 读取临时文件，去掉尾部换行 */
	char *result = NULL;
	size_t rlen = 0;
	if (wsh_read_file(tmp_path, &result, &rlen) == 0 && result) {
		while (rlen > 0 && result[rlen - 1] == '\n') {
			rlen--;
			result[rlen] = '\0';
		}
	}
	remove(tmp_path);

	return result ? result : strdup("");
}
