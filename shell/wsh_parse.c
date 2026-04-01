/*
 * wsh_parse.c — wsh 解析器
 *
 * ; 分割（感知引号和 $() 嵌套）、变量赋值检测。
 * Step 6 将扩展为 if/for/while 的递归下降解析器。
 */
#include <string.h>
#include <ctype.h>
#include "wsh_parse.h"
#include "wsh_vars.h"

/* ===================== ; 分割 ===================== */

int wsh_split_semi(char *input, char *segs[], int max)
{
	int n = 0;
	int depth = 0;      /* $() 嵌套深度 */
	int in_sq = 0;      /* 单引号 */
	int in_dq = 0;      /* 双引号 */

	char *start = input;
	char *p = input;

	while (*p) {
		if (in_sq) {
			if (*p == '\'') in_sq = 0;
			p++;
			continue;
		}
		if (*p == '\'') {
			in_sq = 1;
			p++;
			continue;
		}
		if (in_dq) {
			if (*p == '"') in_dq = 0;
			else if (*p == '\\' && *(p + 1)) p++;
			p++;
			continue;
		}
		if (*p == '"') {
			in_dq = 1;
			p++;
			continue;
		}
		if (*p == '\\' && *(p + 1)) {
			p += 2;
			continue;
		}
		/* 跟踪 $() 嵌套深度 */
		if (*p == '$' && *(p + 1) == '(') {
			depth++;
			p += 2;
			continue;
		}
		if (depth > 0 && *p == ')') {
			depth--;
			p++;
			continue;
		}
		if (depth > 0 && *p == '(') {
			depth++;
			p++;
			continue;
		}
		/* 只有在顶层、不在引号内时才按 ; 分割 */
		if (*p == ';' && depth == 0) {
			*p = '\0';
			while (*start == ' ' || *start == '\t')
				start++;
			if (*start && n < max)
				segs[n++] = start;
			start = p + 1;
		}
		p++;
	}

	/* 最后一段 */
	while (*start == ' ' || *start == '\t')
		start++;
	if (*start && n < max)
		segs[n++] = start;

	return n;
}

/* ===================== 赋值检测 ===================== */

int wsh_try_assign(const char *cmd)
{
	/* 跳过前导空白 */
	while (*cmd == ' ' || *cmd == '\t')
		cmd++;

	/* 必须以字母或下划线开头 */
	if (!*cmd || (!isalpha((unsigned char)*cmd) && *cmd != '_'))
		return 0;

	/* 扫描 NAME 部分 */
	const char *p = cmd;
	while (*p && (isalnum((unsigned char)*p) || *p == '_'))
		p++;

	/* 必须是 '=' */
	if (*p != '=')
		return 0;

	/* '=' 后面不能紧跟 '='（避免 == 比较） */
	if (*(p + 1) == '=')
		return 0;

	/* '=' 后面到结尾不能有空白（确保是赋值不是命令） */
	const char *val = p + 1;
	while (*val) {
		if (*val == ' ' || *val == '\t')
			return 0;
		val++;
	}

	/* 提取 name 和 value */
	int name_len = (int)(p - cmd);
	char name[256];
	if (name_len >= (int)sizeof(name))
		return 0;
	memcpy(name, cmd, name_len);
	name[name_len] = '\0';

	wsh_var_set(name, p + 1);
	return 1;
}
