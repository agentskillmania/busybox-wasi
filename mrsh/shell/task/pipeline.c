/* mrsh/shell/task/pipeline.c — WASM serial pipeline via temp files
 *
 * WASI constraint: after freopen() redirects stdout to a temp file,
 * the original stdout fd is lost and cannot be recovered. Therefore
 * all pipeline stages redirect stdout to temp files, and the final
 * stage's output is emitted via write(STDERR_FILENO, ...) which
 * remains connected to the terminal throughout.
 */
#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "shell/task.h"

/* Defined in simple_command.c — when set, run_process skips its own
 * temp file + stderr output because stdout is already redirected. */
extern int wsh_stdout_redirected;

/* When non-NULL, final output should be written to this capture file
 * (command substitution context). */
extern const char *wsh_capture_file;

#define WSH_PIPE_PREFIX "/tmp/_wsh_p_"

static char *read_entire_file(const char *path, size_t *out_len) {
	FILE *f = fopen(path, "rb");
	if (!f) return NULL;
	fseek(f, 0, SEEK_END);
	long sz = ftell(f);
	fseek(f, 0, SEEK_SET);
	if (sz < 0) { fclose(f); return NULL; }
	char *buf = malloc((size_t)sz + 1);
	if (!buf) { fclose(f); return NULL; }
	size_t n = fread(buf, 1, (size_t)sz, f);
	buf[n] = '\0';
	fclose(f);
	if (out_len) *out_len = n;
	return buf;
}

int run_pipeline(struct mrsh_context *ctx, struct mrsh_pipeline *pl) {
	assert(pl->commands.len > 0);

	/* Single command: no pipe needed, let run_process handle output */
	if (pl->commands.len == 1) {
		int ret = run_command(ctx, pl->commands.data[0]);
		if (pl->bang && ret >= 0) ret = !ret;
		return ret;
	}

	/* Multi-command pipeline: serialize via temp files.
	 *
	 * Every stage redirects stdout to a temp file. The final
	 * stage's temp file is read and written to stderr (the only
	 * fd that reliably reaches the terminal in WASI).
	 */
	int n = (int)pl->commands.len;
	int ret = 0;
	int prev_redirected = wsh_stdout_redirected;
	wsh_stdout_redirected = 1;

	for (int i = 0; i < n; i++) {
		char tmpname[64];
		snprintf(tmpname, sizeof(tmpname), "%s%d_%d", WSH_PIPE_PREFIX,
			(int)getpid(), i);

		/* Read stdin from previous stage's temp file */
		if (i > 0) {
			char prev[64];
			snprintf(prev, sizeof(prev), "%s%d_%d", WSH_PIPE_PREFIX,
				(int)getpid(), i - 1);
			if (freopen(prev, "r", stdin) == NULL) {
				fprintf(stderr, "wsh: pipeline freopen stdin failed: %s\n",
					strerror(errno));
				wsh_stdout_redirected = prev_redirected;
				return 1;
			}
		}

		/* Redirect stdout to temp file for this stage */
		if (freopen(tmpname, "w", stdout) == NULL) {
			fprintf(stderr, "wsh: pipeline freopen stdout failed: %s\n",
				strerror(errno));
			wsh_stdout_redirected = prev_redirected;
			return 1;
		}

		ret = run_command(ctx, pl->commands.data[i]);
		fflush(stdout);

		/* Clean up previous stage's temp file */
		if (i > 0) {
			char prev[64];
			snprintf(prev, sizeof(prev), "%s%d_%d", WSH_PIPE_PREFIX,
				(int)getpid(), i - 1);
			unlink(prev);
		}
	}

	wsh_stdout_redirected = prev_redirected;

	/* Restore stdin */
	freopen("/dev/null", "r", stdin);

	/* Emit final stage output */
	char final_tmp[64];
	snprintf(final_tmp, sizeof(final_tmp), "%s%d_%d", WSH_PIPE_PREFIX,
		(int)getpid(), n - 1);

	size_t len = 0;
	char *output = read_entire_file(final_tmp, &len);
	if (output && len > 0) {
		if (wsh_capture_file) {
			/* Inside command substitution: append to the capture
			 * file so run_word_command can read it back */
			FILE *cap = fopen(wsh_capture_file, "a");
			if (cap) {
				fwrite(output, 1, len, cap);
				fclose(cap);
			}
		} else {
			/* Top-level pipeline: emit to stderr (terminal) */
			write(STDERR_FILENO, output, len);
		}
	}
	free(output);
	unlink(final_tmp);

	if (pl->bang && ret >= 0) ret = !ret;
	return ret;
}
