/*
 * wsh — BusyBox WASM Shell (wasm shell)
 *
 * Step 1: 占位实现，验证编译和调用链路。
 * 不动 BusyBox 的配置系统，通过 build_wasm.sh 单独编译链接。
 * Step 1 不依赖 libbb.h，只验证编译+链接+调用路径。
 */
#include <stdio.h>

int wsh_main(int argc, char **argv)
{
	printf("wsh: step1 ok (argc=%d)\n", argc);
	return 0;
}
