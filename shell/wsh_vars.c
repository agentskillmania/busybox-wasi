/*
 * wsh_vars.c — wsh 变量存储、展开和命令替换
 *
 * 变量存储：线性数组，上限 128 个，线性查找。
 * 展开：逐字符扫描，遇到 $ 触发替换。
 * 命令替换 $()：递归展开 + 临时文件捕获 stdout。
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "wsh_vars.h"
#include "wsh_pipe.h"

/* ===================== 常量 ===================== */

/** 最大变量数 */
#define WSH_MAX_VARS 128

/** 变量名最大长度 */
#define WSH_MAX_NAME 256

/** 展开结果初始缓冲区大小 */
#define WSH_EXPAND_INIT 4096

/* ===================== 变量存储 ===================== */

struct wsh_var {
	char *name;
	char *value;
};

static struct wsh_var g_vars[WSH_MAX_VARS];
static int g_nvars;
static int g_last_exitcode;

/* ===================== 变量操作 ===================== */

void wsh_vars_init(void)
{
	g_nvars = 0;
	g_last_exitcode = 0;
}

void wsh_vars_cleanup(void)
{
	for (int i = 0; i < g_nvars; i++) {
		free(g_vars[i].name);
		free(g_vars[i].value);
	}
	g_nvars = 0;
}

void wsh_var_set(const char *name, const char *value)
{
	/* 查找已有变量 */
	for (int i = 0; i < g_nvars; i++) {
		if (strcmp(g_vars[i].name, name) == 0) {
			free(g_vars[i].value);
			g_vars[i].value = strdup(value);
			return;
		}
	}

	/* 新增 */
	if (g_nvars >= WSH_MAX_VARS) {
		fprintf(stderr, "wsh: too many variables\n");
		return;
	}
	g_vars[g_nvars].name = strdup(name);
	g_vars[g_nvars].value = strdup(value);
	g_nvars++;
}

const char *wsh_var_get(const char *name)
{
	for (int i = 0; i < g_nvars; i++) {
		if (strcmp(g_vars[i].name, name) == 0)
			return g_vars[i].value;
	}
	return NULL;
}

void wsh_set_last_exitcode(int rc)
{
	g_last_exitcode = rc;
}

int wsh_get_last_exitcode(void)
{
	return g_last_exitcode;
}

/* ===================== 子 shell 快照 ===================== */

/** 变量快照结构 */
struct wsh_var_snapshot {
	struct wsh_var *vars;
	int nvars;
	int last_exitcode;
};

struct wsh_var_snapshot *wsh_vars_save(void)
{
	struct wsh_var_snapshot *snap = malloc(sizeof(*snap));
	if (!snap) return NULL;

	snap->vars = NULL;
	snap->nvars = g_nvars;
	snap->last_exitcode = g_last_exitcode;

	if (g_nvars > 0) {
		snap->vars = malloc(sizeof(struct wsh_var) * (size_t)g_nvars);
		if (!snap->vars) {
			free(snap);
			return NULL;
		}
		for (int i = 0; i < g_nvars; i++) {
			snap->vars[i].name = strdup(g_vars[i].name);
			snap->vars[i].value = strdup(g_vars[i].value);
		}
	}

	return snap;
}

void wsh_vars_restore(struct wsh_var_snapshot *snap)
{
	if (!snap) return;

	/* 清理当前变量 */
	for (int i = 0; i < g_nvars; i++) {
		free(g_vars[i].name);
		free(g_vars[i].value);
	}

	/* 从快照恢复（转移所有权，避免二次 strdup） */
	for (int i = 0; i < snap->nvars; i++) {
		g_vars[i].name = snap->vars[i].name;
		g_vars[i].value = snap->vars[i].value;
	}
	g_nvars = snap->nvars;
	g_last_exitcode = snap->last_exitcode;

	free(snap->vars);
	free(snap);
}

/* ===================== 展开辅助 ===================== */

/**
 * 命令替换：递归展开 + 捕获输出。
 * I/O 捕获委托给 wsh_pipe.c 的 wsh_capture_output()。
 *
 * @param cmd  要执行的命令
 * @return 捕获的输出（malloc，调用方 free），失败返回 strdup("")
 */
static char *wsh_command_sub(const char *cmd)
{
	/* 先递归展开内层的变量/替换 */
	char *expanded = wsh_expand(cmd);
	if (!expanded)
		return strdup("");

	char *result = wsh_capture_output(expanded);
	free(expanded);

	return result ? result : strdup("");
}

/* ===================== 动态缓冲区 ===================== */

/** 展开用的动态缓冲区 */
struct exp_buf {
	char *data;
	size_t len;
	size_t cap;
};

static int exp_buf_init(struct exp_buf *b)
{
	b->cap = WSH_EXPAND_INIT;
	b->data = malloc(b->cap);
	if (!b->data)
		return -1;
	b->len = 0;
	b->data[0] = '\0';
	return 0;
}

static int exp_buf_append(struct exp_buf *b, const char *s, size_t slen)
{
	if (b->len + slen + 1 > b->cap) {
		size_t new_cap = b->cap * 2;
		if (new_cap < b->len + slen + 1)
			new_cap = b->len + slen + 1;
		char *new_data = realloc(b->data, new_cap);
		if (!new_data)
			return -1;
		b->data = new_data;
		b->cap = new_cap;
	}
	memcpy(b->data + b->len, s, slen);
	b->len += slen;
	b->data[b->len] = '\0';
	return 0;
}

static void exp_buf_free(struct exp_buf *b)
{
	free(b->data);
}

/* ===================== 变量名提取 ===================== */

/**
 * 从 str[pos] 开始提取变量名（字母/数字/下划线）。
 * @return 变量名长度，0 表示不是有效变量名
 */
static int wsh_read_varname(const char *str, int pos)
{
	int len = 0;
	while (str[pos + len] && (isalnum((unsigned char)str[pos + len])
	       || str[pos + len] == '_')) {
		len++;
	}
	return len;
}

/* ===================== 主展开函数 ===================== */

char *wsh_expand(const char *str)
{
	if (!str)
		return strdup("");

	struct exp_buf buf;
	if (exp_buf_init(&buf) != 0)
		return NULL;

	int i = 0;
	while (str[i]) {
		/* 单引号：原样复制直到匹配的单引号 */
		if (str[i] == '\'') {
			int start = i;
			i++; /* 跳过开头单引号 */
			while (str[i] && str[i] != '\'')
				i++;
			if (str[i] == '\'')
				i++; /* 跳过结尾单引号 */
			/* 包含引号本身一起复制 */
			exp_buf_append(&buf, str + start, i - start);
			continue;
		}

		/* 反斜杠转义：下一个字符原样输出 */
		if (str[i] == '\\' && str[i + 1]) {
			exp_buf_append(&buf, &str[i + 1], 1);
			i += 2;
			continue;
		}

		/* $ 开头的替换 */
		if (str[i] == '$') {
			i++; /* 跳过 $ */

			/* $$ → PID（WASM 里没有真 PID，返回 "1"） */
			if (str[i] == '$') {
				const char *pid = "1";
				exp_buf_append(&buf, pid, strlen(pid));
				i++;
				continue;
			}

			/* $? → 上一个退出码 */
			if (str[i] == '?') {
				char num[16];
				snprintf(num, sizeof(num), "%d", g_last_exitcode);
				exp_buf_append(&buf, num, strlen(num));
				i++;
				continue;
			}

			/* ${NAME} → 带大括号的变量 */
			if (str[i] == '{') {
				i++; /* 跳过 { */
				int name_start = i;
				while (str[i] && str[i] != '}')
					i++;
				int name_len = i - name_start;
				if (str[i] == '}')
					i++; /* 跳过 } */

				char name[WSH_MAX_NAME];
				if (name_len > 0 && name_len < (int)sizeof(name)) {
					memcpy(name, str + name_start, name_len);
					name[name_len] = '\0';
					const char *val = wsh_var_get(name);
					if (val)
						exp_buf_append(&buf, val, strlen(val));
				}
				continue;
			}

			/* $(cmd) → 命令替换 */
			if (str[i] == '(') {
				i++; /* 跳过 ( */

				/* 找到匹配的 )，处理嵌套 $() */
				int depth = 1;
				int cmd_start = i;
				while (str[i] && depth > 0) {
					if (str[i] == '(' && i > 0 && str[i - 1] == '$')
						depth++;
					else if (str[i] == ')')
						depth--;
					if (depth > 0)
						i++;
				}

				int cmd_len = i - cmd_start;
				if (str[i] == ')')
					i++; /* 跳过 ) */

				if (cmd_len > 0) {
					char *cmd = malloc((size_t)cmd_len + 1);
					if (cmd) {
						memcpy(cmd, str + cmd_start, cmd_len);
						cmd[cmd_len] = '\0';
						char *sub = wsh_command_sub(cmd);
						if (sub) {
							exp_buf_append(&buf, sub, strlen(sub));
							free(sub);
						}
						free(cmd);
					}
				}
				continue;
			}

			/* $NAME → 裸变量名 */
			if (isalpha((unsigned char)str[i]) || str[i] == '_') {
				int name_len = wsh_read_varname(str, i);
				if (name_len > 0) {
					char name[WSH_MAX_NAME];
					memcpy(name, str + i, name_len);
					name[name_len] = '\0';
					const char *val = wsh_var_get(name);
					if (val)
						exp_buf_append(&buf, val, strlen(val));
					i += name_len;
				}
				continue;
			}

			/* $ 后面跟的不是有效变量名，原样输出 $ */
			exp_buf_append(&buf, "$", 1);
			continue;
		}

		/* 普通字符 */
		exp_buf_append(&buf, &str[i], 1);
		i++;
	}

	return buf.data;
}
