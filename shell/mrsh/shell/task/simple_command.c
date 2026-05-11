#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <mrsh/ast.h>
#include <mrsh/builtin.h>
#include <mrsh/entry.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <unistd.h>
#include "shell/shell.h"
#include "shell/path.h"
#include "shell/redir.h"
#include "shell/word.h"
#include "shell/task.h"

/* BusyBox applet dispatch (WASM in-process execution) */
extern int find_applet_by_name(const char *name);
extern int (*const applet_main[])(int argc, char **argv);
extern const char *applet_name;
extern void (*die_func)(void);
extern unsigned char xfunc_error_retval;

/* WASM Component Model subcommand dispatch (git/python guests) */
#ifdef COMPONENT_MODE
#include "host_runner.h"
#endif

static jmp_buf wsh_die_jmp;
static void wsh_die_jump(void) {
	longjmp(wsh_die_jmp, xfunc_error_retval | 0x100);
}

static void populate_env_iterator(const char *key, void *_var, void *_) {
	struct mrsh_variable *var = _var;
	if ((var->attribs & MRSH_VAR_ATTRIB_EXPORT)) {
		setenv(key, var->value, 1);
	}
}

/* Flag: when set, stdout is already redirected by pipeline/word_command.
 * When clear, run_simple_command handles temp file + stderr output. */
int wsh_stdout_redirected = 0;

/* When non-NULL, pipeline should append final output to this file
 * instead of stderr. Used by command substitution to capture output. */
const char *wsh_capture_file = NULL;

/* Current file that host's stdout is redirected to.
 * Set alongside every freopen() on stdout.
 * NULL when stdout hasn't been redirected.
 * Used to inform component guests where to write output. */
const char *wsh_stdout_file = NULL;

/* Current file that host's stdin is redirected from.
 * Set alongside every freopen() on stdin.
 * NULL when stdin hasn't been redirected.
 * Used to inform component guests where to read input. */
const char *wsh_stdin_file = NULL;

/* Counter for unique capture temp file names */
static int wsh_out_counter = 0;

#define WSH_CAPTURE_PREFIX "/tmp/_wsh_c_"

static int run_process(struct mrsh_context *ctx, struct mrsh_simple_command *sc,
		char **argv) {
	struct mrsh_state *state = ctx->state;
	struct mrsh_state_priv *priv = state_get_priv(state);

	/* Apply assignments to environment */
	for (size_t i = 0; i < sc->assignments.len; ++i) {
		struct mrsh_assignment *assign = sc->assignments.data[i];
		uint32_t prev_attribs;
		if (mrsh_env_get(state, assign->name, &prev_attribs)
				&& (prev_attribs & MRSH_VAR_ATTRIB_READONLY)) {
			fprintf(stderr, "cannot modify readonly variable %s\n",
					assign->name);
			return TASK_STATUS_ERROR;
		}
		char *value = mrsh_word_str(assign->value);
		setenv(assign->name, value, true);
		free(value);
	}

	mrsh_hashtable_for_each(&priv->variables, populate_env_iterator, NULL);

	/* Count argc */
	int argc = 0;
	while (argv[argc]) argc++;

		/* Apply I/O redirects using freopen() since dup2 is a stub in WASI.
		 * Each redirect reassigns the FILE* so C stdio stays in sync.
		 * Track redirect file paths for component guest dispatch. */
		char proc_stdout_file[256] = "";
		char proc_stdin_file[256] = "";
		for (size_t i = 0; i < sc->io_redirects.len; ++i) {
			struct mrsh_io_redirect *redir = sc->io_redirects.data[i];
			int redir_fd;
			int fd = process_redir(redir, &redir_fd);
			if (fd < 0) {
				return TASK_STATUS_ERROR;
			}
			char *fname = mrsh_word_str(redir->name);
			bool ok = false;
			if (redir_fd == STDOUT_FILENO) {
				const char *mode = "w";
				if (redir->op == MRSH_IO_DGREAT)
					mode = "a";
				fflush(stdout);
				ok = freopen(fname, mode, stdout) != NULL;
				snprintf(proc_stdout_file, sizeof(proc_stdout_file), "%s", fname);
			} else if (redir_fd == STDIN_FILENO) {
				fflush(stdin);
				ok = freopen(fname, "r", stdin) != NULL;
				snprintf(proc_stdin_file, sizeof(proc_stdin_file), "%s", fname);
			} else if (redir_fd == STDERR_FILENO) {
				const char *mode = "w";
				if (redir->op == MRSH_IO_DGREAT)
					mode = "a";
				fflush(stderr);
				ok = freopen(fname, mode, stderr) != NULL;
			} else {
				fprintf(stderr, "wsh: cannot redirect fd %d\n", redir_fd);
			}
			free(fname);
			close(fd);
			if (!ok) {
				return TASK_STATUS_ERROR;
			}
		}

		/* Update global redirect tracking for component guests */
		if (proc_stdout_file[0]) wsh_stdout_file = proc_stdout_file;
		if (proc_stdin_file[0]) wsh_stdin_file = proc_stdin_file;

	/* Look up BusyBox applet */
	int idx = find_applet_by_name(argv[0]);
	if (idx < 0) {
#ifdef COMPONENT_MODE
		/* Fall back to component guest dispatch (git/python) */
		if (strcmp(argv[0], "git") == 0
		    || strcmp(argv[0], "python") == 0
		    || strcmp(argv[0], "python3") == 0) {
			host_runner_list_string_t cm_args = {NULL, argc};
			cm_args.ptr = malloc(sizeof(host_runner_string_t) * argc);
			for (int i = 0; i < argc; i++)
				host_runner_string_dup(&cm_args.ptr[i], argv[i]);

			host_runner_string_t cwd;
			char cwd_buf[4096];
			if (getcwd(cwd_buf, sizeof(cwd_buf)))
				host_runner_string_dup(&cwd, cwd_buf);
			else
				host_runner_string_dup(&cwd, "/");

			host_runner_string_t stdout_f, stdin_f;
			host_runner_string_dup(&stdout_f, wsh_stdout_file ? wsh_stdout_file : "");
			host_runner_string_dup(&stdin_f, wsh_stdin_file ? wsh_stdin_file : "");

			int rc;
			if (strcmp(argv[0], "git") == 0)
				rc = agentskillmania_subcommand_git_execute(&cwd, &cm_args, &stdout_f, &stdin_f);
			else
				rc = agentskillmania_subcommand_python_execute(&cwd, &cm_args, &stdout_f, &stdin_f);

			fflush(stdout);
			host_runner_string_free(&cwd);
			host_runner_string_free(&stdout_f);
			host_runner_string_free(&stdin_f);
			host_runner_list_string_free(&cm_args);
			return rc;
		}
#endif
		fprintf(stderr, "wsh: %s: applet not found\n", argv[0]);
		return 127;
	}

	/* Copy argv so applet's getopt32/mutating argv ops don't
	 * corrupt our args array. Some applets (wc, head) do
	 * *--argv = bb_msg_standard_input, replacing our strdup'd
	 * strings with static pointers that crash on free(). */
	char **argv_copy = malloc((argc + 1) * sizeof(char *));
	for (int i = 0; i < argc; i++)
		argv_copy[i] = argv[i];
	argv_copy[argc] = NULL;

	/* Save BusyBox global state */
	const char *saved_applet_name = applet_name;
	void (*saved_die_func)(void) = die_func;
	unsigned char saved_error_retval = xfunc_error_retval;
	extern int optind;
	optind = 1;

	/* Set up setjmp protection against BusyBox xfunc_die() */
	die_func = wsh_die_jump;
	applet_name = argv[0];
	xfunc_error_retval = 0;

	int ret;
	int jmp_val = setjmp(wsh_die_jmp);
	if (jmp_val == 0) {
		ret = applet_main[idx](argc, argv_copy);
	} else {
		ret = jmp_val & 0xFF;
	}

	free(argv_copy);

	fflush(stdout);

	/* Restore BusyBox global state */
	applet_name = saved_applet_name;
	die_func = saved_die_func;
	xfunc_error_retval = saved_error_retval;

	return ret;
}

static int run_builtin(struct mrsh_context *ctx, struct mrsh_simple_command *sc,
		int argc, char **argv) {
	for (size_t i = 0; i < sc->io_redirects.len; ++i) {
		struct mrsh_io_redirect *redir = sc->io_redirects.data[i];
		int redir_fd;
		int fd = process_redir(redir, &redir_fd);
		if (fd < 0) {
			return TASK_STATUS_ERROR;
		}
		char *fname = mrsh_word_str(redir->name);
		bool ok = false;
		if (redir_fd == STDIN_FILENO) {
			fflush(stdin);
			ok = freopen(fname, "r", stdin) != NULL;
		} else if (redir_fd == STDOUT_FILENO) {
			const char *mode = "w";
			if (redir->op == MRSH_IO_DGREAT)
				mode = "a";
			fflush(stdout);
			ok = freopen(fname, mode, stdout) != NULL;
		} else if (redir_fd == STDERR_FILENO) {
			const char *mode = "w";
			if (redir->op == MRSH_IO_DGREAT)
				mode = "a";
			fflush(stderr);
			ok = freopen(fname, mode, stderr) != NULL;
		} else {
			fprintf(stderr, "wsh: cannot redirect fd %d\n", redir_fd);
		}
		free(fname);
		close(fd);
		if (!ok) {
			return TASK_STATUS_ERROR;
		}

	}

	int ret = mrsh_run_builtin(ctx->state, argc, argv);

	fflush(stdout);
	fflush(stderr);

	return ret;
}

static int run_assignments(struct mrsh_context *ctx, struct mrsh_array *assignments) {
	for (size_t i = 0; i < assignments->len; ++i) {
		struct mrsh_assignment *assign = assignments->data[i];
		char *new_value = mrsh_word_str(assign->value);
		uint32_t attribs = MRSH_VAR_ATTRIB_NONE;
		if ((ctx->state->options & MRSH_OPT_ALLEXPORT)) {
			attribs = MRSH_VAR_ATTRIB_EXPORT;
		}
		uint32_t prev_attribs = 0;
		if (mrsh_env_get(ctx->state, assign->name, &prev_attribs) != NULL
				&& (prev_attribs & MRSH_VAR_ATTRIB_READONLY)) {
			free(new_value);
			fprintf(stderr, "cannot modify readonly variable %s\n",
				assign->name);
			return TASK_STATUS_ERROR;
		}
		mrsh_env_set(ctx->state, assign->name, new_value, attribs);
		free(new_value);
	}

	return 0;
}

static int expand_assignments(struct mrsh_context *ctx,
		struct mrsh_array *assignments) {
	for (size_t i = 0; i < assignments->len; ++i) {
		struct mrsh_assignment *assign = assignments->data[i];
		expand_tilde(ctx->state, &assign->value, true);
		int ret = run_word(ctx, &assign->value);
		if (ret < 0) {
			return ret;
		}
	}
	return 0;
}

static struct mrsh_simple_command *copy_simple_command(
		const struct mrsh_simple_command *sc) {
	struct mrsh_command *cmd = mrsh_command_copy(&sc->command);
	return mrsh_command_get_simple_command(cmd);
}

int run_simple_command(struct mrsh_context *ctx, struct mrsh_simple_command *sc) {
	struct mrsh_state *state = ctx->state;
	struct mrsh_state_priv *priv = state_get_priv(state);

	if (sc->name == NULL) {
		struct mrsh_array assignments = {0};
		mrsh_array_reserve(&assignments, sc->assignments.len);
		for (size_t i = 0; i < sc->assignments.len; ++i) {
			struct mrsh_assignment *assign = sc->assignments.data[i];
			mrsh_array_add(&assignments, mrsh_assignment_copy(assign));
		}

		int ret = expand_assignments(ctx, &assignments);
		if (ret < 0) {
			return ret;
		}

		ret = run_assignments(ctx, &assignments);
		if (ret < 0) {
			return ret;
		}

		for (size_t i = 0; i < assignments.len; ++i) {
			struct mrsh_assignment *assign = assignments.data[i];
			mrsh_assignment_destroy(assign);
		}
		mrsh_array_finish(&assignments);

		return 0;
	}

	sc = copy_simple_command(sc);

	struct mrsh_array args = {0};
	int ret = expand_word(ctx, sc->name, &args);
	if (ret < 0) {
		return ret;
	}
	for (size_t i = 0; i < sc->arguments.len; ++i) {
		struct mrsh_word *arg = sc->arguments.data[i];
		ret = expand_word(ctx, arg, &args);
		if (ret < 0) {
			return ret;
		}
	}
	assert(args.len > 0);
	mrsh_array_add(&args, NULL);

	ret = expand_assignments(ctx, &sc->assignments);
	if (ret < 0) {
		return ret;
	}

	for (size_t i = 0; i < sc->io_redirects.len; ++i) {
		struct mrsh_io_redirect *redir = sc->io_redirects.data[i];
		expand_tilde(state, &redir->name, false);
		ret = run_word(ctx, &redir->name);
		if (ret < 0) {
			return ret;
		}
		for (size_t j = 0; j < redir->here_document.len; ++j) {
			struct mrsh_word **line_word_ptr =
				(struct mrsh_word **)&redir->here_document.data[j];
			expand_tilde(state, line_word_ptr, false);
			ret = run_word(ctx, line_word_ptr);
			if (ret < 0) {
				return ret;
			}
		}
	}

	char **argv = (char **)args.data;
	int argc = args.len - 1;
	const char *argv_0 = argv[0];

	if ((state->options & MRSH_OPT_XTRACE)) {
		char *ps4 = mrsh_get_ps4(state);
		fprintf(stderr, "%s", ps4);
		for (int i = 0; i < argc; ++i) {
			fprintf(stderr, "%s%s", i > 0 ? " " : "", argv[i]);
		}
		fprintf(stderr, "\n");
		free(ps4);
	}

	/* Capture setup: redirect stdout to a temp file so that subsequent
	 * commands can restore fd 1 after redirects. Without dup() (not
	 * available in WASI Preview2), freopen() permanently changes fd 1.
	 * The next command's capture freopen restores fd 1 to a new file.
	 * Skip when pipeline or command substitution manages stdout. */
	char capture_tmp[64] = {0};
	int need_capture = !wsh_stdout_redirected;
	if (need_capture) {
		snprintf(capture_tmp, sizeof(capture_tmp), "%s%d_%d",
			WSH_CAPTURE_PREFIX, (int)getpid(), wsh_out_counter++);
		fflush(stdout);
		if (freopen(capture_tmp, "w", stdout) == NULL) {
			capture_tmp[0] = '\0';
			need_capture = 0;
		} else {
			wsh_stdout_file = capture_tmp;
		}
	}

	ret = -1;
	const struct mrsh_function *fn_def =
		mrsh_hashtable_get(&priv->functions, argv_0);
	if (fn_def != NULL) {
		push_frame(state, argc, (const char **)argv);
		struct mrsh_command *body = mrsh_command_copy(fn_def->body);
		ret = run_command(ctx, body);
		mrsh_command_destroy(body);
		pop_frame(state);
	} else if (mrsh_has_builtin(argv_0)) {
		ret = run_builtin(ctx, sc, argc, argv);
	} else {
		ret = run_process(ctx, sc, argv);
	}

	/* Capture emission: read temp file and write to stderr */
	if (need_capture && capture_tmp[0]) {
		fflush(stdout);
		FILE *f = fopen(capture_tmp, "rb");
		if (f) {
			char buf[4096];
			size_t n;
			while ((n = fread(buf, 1, sizeof(buf), f)) > 0) {
				write(STDERR_FILENO, buf, n);
			}
			fclose(f);
		}
		unlink(capture_tmp);
	}

	mrsh_command_destroy(&sc->command);
	for (size_t i = 0; i < args.len; ++i) {
		free(args.data[i]);
	}
	mrsh_array_finish(&args);
	return ret;
}
