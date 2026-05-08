//applet:IF_WSH(APPLET(wsh, BB_DIR_BIN, BB_SUID_DROP))
//kbuild:lib-$(CONFIG_SHELL_WSH) += wsh.o
//usage:#define wsh_trivial_usage
//usage:       "[-c CMD]"
//usage:#define wsh_full_usage "\n\n"
//usage:       "POSIX shell (mrsh) for WASM environments"

/*
 * wsh — BusyBox WASM Shell entry point
 *
 * Thin wrapper: init mrsh state -> parse input -> execute.
 * All parsing and execution is handled by mrsh.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <mrsh/parser.h>
#include <mrsh/shell.h>
#include <mrsh/entry.h>

int wsh_main(int argc, char **argv)
{
	if (argc < 3 || strcmp(argv[1], "-c") != 0) {
		fprintf(stderr, "wsh: usage: wsh -c \"command\"\n");
		return 1;
	}

	struct mrsh_state *state = mrsh_state_create();
	if (!state) {
		fprintf(stderr, "wsh: failed to create shell state\n");
		return 1;
	}

	mrsh_populate_env(state, environ);

	struct mrsh_parser *parser = mrsh_parser_with_data(argv[2], strlen(argv[2]));
	if (!parser) {
		fprintf(stderr, "wsh: failed to create parser\n");
		mrsh_state_destroy(state);
		return 1;
	}

	int ret = 0;
	struct mrsh_program *prog = mrsh_parse_program(parser);

	const char *err = mrsh_parser_error(parser, NULL);
	if (err) {
		fprintf(stderr, "wsh: syntax error: %s\n", err);
		ret = 2;
	} else if (prog) {
		ret = mrsh_run_program(state, prog);
		mrsh_program_destroy(prog);
	}

	mrsh_parser_destroy(parser);
	mrsh_state_destroy(state);
	return ret;
}
