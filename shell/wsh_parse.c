/*
 * wsh_parse.c — wsh 递归下降解析器
 *
 * tokenize → parse_list → parse_if/for/while/exec_segment。
 * 嵌套感知：if 内可套 if/for/while，for 内可套 if 等。
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "wsh_parse.h"
#include "wsh_vars.h"
#include "wsh_pipe.h"

/* ===================== Token ===================== */

enum {
	WSH_TOK_WORD,
	WSH_TOK_SEMI,
	WSH_TOK_EOF
};

struct wsh_tok {
	const char *start;
	int len;
	int type;
};

#define WSH_MAX_TOKENS 4096

/* ===================== 分词器 ===================== */

/**
 * 将输入字符串切分为 token 数组。
 * 引号和 $() 内部不分割。
 */
static int wsh_tokenize(const char *input, struct wsh_tok *toks, int max)
{
	int n = 0;
	int i = 0;

	while (input[i] && n < max - 1) {
		/* 跳过空白 */
		while (input[i] == ' ' || input[i] == '\t' || input[i] == '\n')
			i++;
		if (!input[i])
			break;

		/* ; */
		if (input[i] == ';') {
			toks[n].start = &input[i];
			toks[n].len = 1;
			toks[n].type = WSH_TOK_SEMI;
			n++; i++;
			continue;
		}

		/* Word：引号和 $() 内不分割 */
		int start = i;
		int in_sq = 0, in_dq = 0, depth = 0;

		while (input[i]) {
			if (in_sq) {
				if (input[i] == '\'') in_sq = 0;
				i++; continue;
			}
			if (input[i] == '\'') { in_sq = 1; i++; continue; }
			if (in_dq) {
				if (input[i] == '"') in_dq = 0;
				else if (input[i] == '\\' && input[i + 1]) i++;
				i++; continue;
			}
			if (input[i] == '"') { in_dq = 1; i++; continue; }
			if (input[i] == '\\' && input[i + 1]) { i += 2; continue; }
			if (input[i] == '$' && input[i + 1] == '(') {
				depth++; i += 2; continue;
			}
			if (depth > 0) {
				if (input[i] == ')') depth--;
				else if (input[i] == '(') depth++;
				i++; continue;
			}
			if (input[i] == ' ' || input[i] == '\t' ||
			    input[i] == '\n' || input[i] == ';')
				break;
			i++;
		}

		toks[n].start = &input[start];
		toks[n].len = i - start;
		toks[n].type = WSH_TOK_WORD;
		n++;
	}

	/* EOF 哨兵 */
	toks[n].start = &input[i];
	toks[n].len = 0;
	toks[n].type = WSH_TOK_EOF;
	n++;
	return n;
}

/* ===================== Token 辅助 ===================== */

static int tok_is(const struct wsh_tok *t, const char *kw)
{
	if (t->type != WSH_TOK_WORD)
		return 0;
	int klen = (int)strlen(kw);
	return t->len == klen && strncmp(t->start, kw, t->len) == 0;
}

static char *tok_dup(const struct wsh_tok *t)
{
	char *s = malloc(t->len + 1);
	memcpy(s, t->start, t->len);
	s[t->len] = '\0';
	return s;
}

/** 从 token 范围重建原始子串 */
static char *toks_to_str(const struct wsh_tok *toks, int start, int end)
{
	if (start >= end)
		return strdup("");
	const char *s = toks[start].start;
	const char *e = toks[end - 1].start + toks[end - 1].len;
	size_t len = (size_t)(e - s);
	char *str = malloc(len + 1);
	memcpy(str, s, len);
	str[len] = '\0';
	return str;
}

/* ===================== 嵌套感知关键字查找 ===================== */

/**
 * 在 token 范围内查找多个关键字中最早出现的一个。
 *
 * 只在"命令边界"匹配（输入起始或 ; 之后）。
 * init_if_depth/init_loop_depth 用于外层块已占用的嵌套深度。
 *
 * @return 关键字 token 位置，-1 未找到
 */
static int find_kw(const struct wsh_tok *toks, int pos, int end,
                   const char **kws, int nkws, int *which,
                   int init_if_depth, int init_loop_depth)
{
	int at_boundary = 1;
	int if_d = init_if_depth, loop_d = init_loop_depth;

	while (pos < end) {
		if (toks[pos].type == WSH_TOK_SEMI) {
			at_boundary = 1; pos++; continue;
		}
		if (toks[pos].type != WSH_TOK_WORD) {
			at_boundary = 0; pos++; continue;
		}

		/* 先尝试匹配（在边界 + 当前深度 == 初始深度时） */
		if (at_boundary && if_d == init_if_depth
		                && loop_d == init_loop_depth) {
			for (int k = 0; k < nkws; k++) {
				if (tok_is(&toks[pos], kws[k])) {
					if (which) *which = k;
					return pos;
				}
			}
		}

		/* 然后更新嵌套深度 */
		if (tok_is(&toks[pos], "if"))
			if_d++;
		else if (tok_is(&toks[pos], "fi"))
			if_d--;
		else if (tok_is(&toks[pos], "for") || tok_is(&toks[pos], "while"))
			loop_d++;
		else if (tok_is(&toks[pos], "done"))
			loop_d--;

		at_boundary = 0;
		pos++;
	}
	return -1;
}

/* ===================== Forward declarations ===================== */

static int wsh_parse_list(const struct wsh_tok *toks, int pos, int end);

/* ===================== 简单命令执行 ===================== */

/**
 * 执行一个简单命令段。
 * 重建字符串 → 展开变量 → 赋值检测 → 管道执行。
 */
static int wsh_exec_segment(const struct wsh_tok *toks, int start, int end)
{
	char *raw = toks_to_str(toks, start, end);
	if (!raw || !*raw) { free(raw); return 0; }

	char *expanded = wsh_expand(raw);
	free(raw);
	if (!expanded) return 0;

	if (wsh_try_assign(expanded)) {
		free(expanded);
		return 0;
	}

	int rc = wsh_run_pipeline(expanded);
	wsh_set_last_exitcode(rc);
	free(expanded);
	return rc;
}

/* ===================== if 解析 ===================== */

static int wsh_parse_if(const struct wsh_tok *toks, int pos, int end, int *rc)
{
	*rc = 0;
	pos++; /* 跳过 'if' */

	const char *then_kws[] = {"then"};
	const char *block_kws[] = {"elif", "else", "fi"};
	const char *fi_kws[] = {"fi"};

	while (1) {
		/* 找 then */
		int w;
		int then_pos = find_kw(toks, pos, end, then_kws, 1, NULL, 0, 0);
		if (then_pos < 0) {
			fprintf(stderr, "wsh: if: missing 'then'\n");
			*rc = 1;
			return end;
		}

		/* 执行条件 */
		int cond_rc = wsh_parse_list(toks, pos, then_pos);

		/* 找 elif/else/fi（body 区域的嵌套 if 深度从 1 开始，
		 * 因为当前 if 已占据一层） */
		int which;
		int block_pos = find_kw(toks, then_pos + 1, end,
		                        block_kws, 3, &which, 1, 0);
		if (block_pos < 0) {
			fprintf(stderr, "wsh: if: missing 'fi'\n");
			*rc = 1;
			return end;
		}

		if (cond_rc == 0) {
			/* 条件为真：执行 then-body */
			*rc = wsh_parse_list(toks, then_pos + 1, block_pos);

			/* 跳到匹配的 fi */
			if (which != 2) { /* elif 或 else → 需要找 fi */
				int fi_pos = find_kw(toks, block_pos + 1, end,
				                     fi_kws, 1, NULL, 1, 0);
				if (fi_pos < 0) fi_pos = end - 1;
				return fi_pos + 1;
			}
			return block_pos + 1; /* fi */
		}

		/* 条件为假 */
		if (which == 0) { /* elif → 下一轮迭代 */
			pos = block_pos + 1;
			continue;
		}
		if (which == 1) { /* else */
			int fi_pos = find_kw(toks, block_pos + 1, end,
			                     fi_kws, 1, NULL, 1, 0);
			if (fi_pos < 0) {
				fprintf(stderr, "wsh: if: missing 'fi'\n");
				*rc = 1;
				return end;
			}
			*rc = wsh_parse_list(toks, block_pos + 1, fi_pos);
			return fi_pos + 1;
		}
		/* fi（无 else） */
		return block_pos + 1;
	}
}

/* ===================== for 解析 ===================== */

#define WSH_MAX_LOOP_ITER 10000

static int wsh_parse_for(const struct wsh_tok *toks, int pos, int end, int *rc)
{
	*rc = 0;
	pos++; /* 跳过 'for' */

	/* 变量名 */
	if (pos >= end || toks[pos].type != WSH_TOK_WORD) {
		fprintf(stderr, "wsh: for: missing variable name\n");
		*rc = 1;
		return end;
	}
	char *varname = tok_dup(&toks[pos]);
	pos++;

	/* 期望 'in' */
	if (pos >= end || !tok_is(&toks[pos], "in")) {
		fprintf(stderr, "wsh: for: expected 'in'\n");
		free(varname);
		*rc = 1;
		return end;
	}
	pos++; /* 跳过 'in' */

	/* 找 'do' */
	const char *do_kws[] = {"do"};
	int do_pos = find_kw(toks, pos, end, do_kws, 1, NULL, 0, 0);
	if (do_pos < 0) {
		fprintf(stderr, "wsh: for: missing 'do'\n");
		free(varname);
		*rc = 1;
		return end;
	}

	/* 找 'done'（body 区域 loop 深度从 1 开始） */
	const char *done_kws[] = {"done"};
	int done_pos = find_kw(toks, do_pos + 1, end,
	                       done_kws, 1, NULL, 0, 1);
	if (done_pos < 0) {
		fprintf(stderr, "wsh: for: missing 'done'\n");
		free(varname);
		*rc = 1;
		return end;
	}

	/* 展开 word list：收集 pos 到 do_pos 之间的 word token */
	char **word_list = malloc(WSH_MAX_LOOP_ITER * sizeof(char *));
	int nwords = 0;
	for (int i = pos; i < do_pos; i++) {
		if (toks[i].type != WSH_TOK_WORD)
			continue;
		char *raw = tok_dup(&toks[i]);
		char *exp = wsh_expand(raw);
		free(raw);
		if (exp && *exp) {
			word_list[nwords++] = exp;
		} else {
			free(exp);
		}
	}

	/* 循环执行 body */
	for (int i = 0; i < nwords; i++) {
		wsh_var_set(varname, word_list[i]);
		*rc = wsh_parse_list(toks, do_pos + 1, done_pos);
	}

	for (int i = 0; i < nwords; i++)
		free(word_list[i]);
	free(word_list);
	free(varname);
	return done_pos + 1;
}

/* ===================== while 解析 ===================== */

static int wsh_parse_while(const struct wsh_tok *toks, int pos, int end, int *rc)
{
	*rc = 0;
	pos++; /* 跳过 'while' */

	/* 找 'do' */
	const char *do_kws[] = {"do"};
	int do_pos = find_kw(toks, pos, end, do_kws, 1, NULL, 0, 0);
	if (do_pos < 0) {
		fprintf(stderr, "wsh: while: missing 'do'\n");
		*rc = 1;
		return end;
	}

	/* 找 'done'（body 区域 loop 深度从 1 开始） */
	const char *done_kws[] = {"done"};
	int done_pos = find_kw(toks, do_pos + 1, end,
	                       done_kws, 1, NULL, 0, 1);
	if (done_pos < 0) {
		fprintf(stderr, "wsh: while: missing 'done'\n");
		*rc = 1;
		return end;
	}

	/* 循环 */
	for (int i = 0; i < WSH_MAX_LOOP_ITER; i++) {
		int cond_rc = wsh_parse_list(toks, pos, do_pos);
		if (cond_rc != 0)
			break;
		*rc = wsh_parse_list(toks, do_pos + 1, done_pos);
	}

	return done_pos + 1;
}

/* ===================== 命令列表解析 ===================== */

/**
 * 解析并执行 token 范围内的命令列表。
 * 顶层循环：跳过 ; → 检测复合命令 → 执行简单命令。
 */
static int wsh_parse_list(const struct wsh_tok *toks, int pos, int end)
{
	int rc = 0;

	while (pos < end) {
		/* 跳过分号 */
		if (toks[pos].type == WSH_TOK_SEMI) {
			pos++;
			continue;
		}
		if (toks[pos].type == WSH_TOK_EOF)
			break;

		/* 复合命令 */
		if (toks[pos].type == WSH_TOK_WORD) {
			if (tok_is(&toks[pos], "if")) {
				pos = wsh_parse_if(toks, pos, end, &rc);
				wsh_set_last_exitcode(rc);
				continue;
			}
			if (tok_is(&toks[pos], "for")) {
				pos = wsh_parse_for(toks, pos, end, &rc);
				wsh_set_last_exitcode(rc);
				continue;
			}
			if (tok_is(&toks[pos], "while")) {
				pos = wsh_parse_while(toks, pos, end, &rc);
				wsh_set_last_exitcode(rc);
				continue;
			}
		}

		/* 简单命令：收集到下一个 ; */
		int cmd_start = pos;
		while (pos < end &&
		       toks[pos].type != WSH_TOK_SEMI &&
		       toks[pos].type != WSH_TOK_EOF) {
			pos++;
		}
		if (pos > cmd_start)
			rc = wsh_exec_segment(toks, cmd_start, pos);
	}

	return rc;
}

/* ===================== 赋值检测 ===================== */

int wsh_try_assign(const char *cmd)
{
	while (*cmd == ' ' || *cmd == '\t')
		cmd++;

	if (!*cmd || (!isalpha((unsigned char)*cmd) && *cmd != '_'))
		return 0;

	const char *p = cmd;
	while (*p && (isalnum((unsigned char)*p) || *p == '_'))
		p++;

	if (*p != '=' || *(p + 1) == '=')
		return 0;

	const char *val = p + 1;
	while (*val) {
		if (*val == ' ' || *val == '\t')
			return 0;
		val++;
	}

	int name_len = (int)(p - cmd);
	char name[256];
	if (name_len >= (int)sizeof(name))
		return 0;
	memcpy(name, cmd, name_len);
	name[name_len] = '\0';

	wsh_var_set(name, p + 1);
	return 1;
}

/* ===================== 公共入口 ===================== */

int wsh_execute_input(const char *input)
{
	struct wsh_tok toks[WSH_MAX_TOKENS];
	int ntok = wsh_tokenize(input, toks, WSH_MAX_TOKENS);
	return wsh_parse_list(toks, 0, ntok);
}
