/*
 * wsh — BusyBox WASM Shell (wasm shell)
 *
 * 纯调度器：解析参数 → 分割命令 → 展开变量 → 检测赋值 → 执行管道。
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "wsh_pipe.h"
#include "wsh_vars.h"
#include "wsh_parse.h"

/** 最大命令段数（; 分割） */
#define WSH_MAX_SEGS 256

/**
 * wsh 主入口。
 * 用法: wsh -c "command"
 */
int wsh_main(int argc, char **argv)
{
	if (argc < 3 || strcmp(argv[1], "-c") != 0) {
		fprintf(stderr, "wsh: usage: wsh -c \"command\"\n");
		return 1;
	}

	wsh_vars_init();

	char *buf = strdup(argv[2]);
	if (!buf) {
		fprintf(stderr, "wsh: out of memory\n");
		return 1;
	}

	/* 按 ; 分割 */
	char *segs[WSH_MAX_SEGS];
	int nseg = wsh_split_semi(buf, segs, WSH_MAX_SEGS);

	int last_rc = 0;
	for (int i = 0; i < nseg; i++) {
		/* 展开变量和命令替换 */
		char *expanded = wsh_expand(segs[i]);
		if (!expanded)
			continue;

		/* 检测变量赋值 */
		if (wsh_try_assign(expanded)) {
			free(expanded);
			continue;
		}

		/* 执行管道 */
		last_rc = wsh_run_pipeline(expanded);
		wsh_set_last_exitcode(last_rc);
		free(expanded);
	}

	free(buf);
	wsh_vars_cleanup();
	return last_rc;
}
