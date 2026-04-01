/*
 * wsh — BusyBox WASM Shell (wasm shell)
 *
 * 入口模块：解析 -c 参数，调用管道执行引擎。
 * 管道逻辑在 wsh_pipe.c 中实现。
 */
#include <stdio.h>
#include <string.h>
#include "wsh_pipe.h"

/**
 * wsh 主入口。
 * 用法: wsh -c "command arg1 arg2 ..."
 */
int wsh_main(int argc, char **argv)
{
	/* 解析参数：wsh -c "command" */
	if (argc < 3 || strcmp(argv[1], "-c") != 0) {
		fprintf(stderr, "wsh: usage: wsh -c \"command\"\n");
		return 1;
	}

	return wsh_run_pipeline(argv[2]);
}
