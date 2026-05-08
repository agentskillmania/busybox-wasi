/* mrsh/shell/task/pipeline.c — WASM serial pipeline via temp files */
#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "shell/task.h"

#define WSH_PIPE_PREFIX "/tmp/_wsh_p_"

int run_pipeline(struct mrsh_context *ctx, struct mrsh_pipeline *pl) {
	assert(pl->commands.len > 0);

	/* Single command: no pipe needed */
	if (pl->commands.len == 1) {
		int ret = run_command(ctx, pl->commands.data[0]);
		if (pl->bang && ret >= 0) ret = !ret;
		return ret;
	}

	/* Multi-command pipeline: serialize via temp files */
	int n = (int)pl->commands.len;
	int ret = 0;

	for (int i = 0; i < n; i++) {
		char tmpname[64];
		snprintf(tmpname, sizeof(tmpname), "%s%d_%d", WSH_PIPE_PREFIX,
			(int)getpid(), i);

		if (i < n - 1) {
			/* Redirect stdout to temp file for this stage */
			FILE *saved = stdout;
			stdout = freopen(tmpname, "w", stdout);
			if (!stdout) {
				fprintf(stderr, "wsh: pipeline freopen failed: %s\n",
					strerror(errno));
				stdout = saved;
				return 1;
			}

			ret = run_command(ctx, pl->commands.data[i]);
			fflush(stdout);
			fclose(stdout);

			/* Restore stdout from stderr */
			stdout = fdopen(2, "w");

			/* Next stage reads from this temp file */
			stdin = freopen(tmpname, "r", stdin);
			if (!stdin) {
				fprintf(stderr, "wsh: pipeline freopen stdin failed: %s\n",
					strerror(errno));
				unlink(tmpname);
				return 1;
			}
		} else {
			/* Last stage: reads from prev temp file, writes to real stdout */
			ret = run_command(ctx, pl->commands.data[i]);
			fclose(stdin);
			stdin = fopen("/dev/null", "r");
		}

		unlink(tmpname);
	}

	if (pl->bang && ret >= 0) ret = !ret;
	return ret;
}
