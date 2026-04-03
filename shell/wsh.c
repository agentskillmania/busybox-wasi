//applet:IF_WSH(APPLET(wsh, BB_DIR_BIN, BB_SUID_DROP))
//kbuild:lib-$(CONFIG_SHELL_WSH) += wsh.o wsh_pipe.o wsh_vars.o wsh_parse.o
//usage:#define wsh_trivial_usage
//usage:       "[-c CMD]"
//usage:#define wsh_full_usage "\n\n"
//usage:       "WASM shell for single-process environments"

/*
 * wsh — BusyBox WASM Shell (wasm shell)
 *
 * 纯调度器：解析参数，调用解析器执行。
 */
#include <stdio.h>
#include <string.h>
#include "wsh_parse.h"
#include "wsh_vars.h"

int wsh_main(int argc, char **argv)
{
	if (argc < 3 || strcmp(argv[1], "-c") != 0) {
		fprintf(stderr, "wsh: usage: wsh -c \"command\"\n");
		return 1;
	}

	wsh_vars_init();
	int rc = wsh_execute_input(argv[2]);
	wsh_vars_cleanup();
	return rc;
}
