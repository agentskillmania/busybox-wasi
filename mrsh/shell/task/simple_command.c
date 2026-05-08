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

	/* Look up BusyBox applet */
	int idx = find_applet_by_name(argv[0]);
	if (idx < 0) {
		fprintf(stderr, "wsh: %s: applet not found\n", argv[0]);
		return 127;
	}

	/* Count argc */
	int argc = 0;
	while (argv[argc]) argc++;

	/* Save BusyBox global state */
	const char *saved_applet_name = applet_name;
	void (*saved_die_func)(void) = die_func;
	unsigned char saved_error_retval = xfunc_error_retval;

	/* Set up setjmp protection against BusyBox xfunc_die() */
	die_func = wsh_die_jump;
	applet_name = argv[0];
	xfunc_error_retval = 0;

	int ret;
	int jmp_val = setjmp(wsh_die_jmp);
	if (jmp_val == 0) {
		ret = applet_main[idx](argc, argv);
	} else {
		ret = jmp_val & 0xFF;
	}

	/* Restore BusyBox global state */
	applet_name = saved_applet_name;
	die_func = saved_die_func;
	xfunc_error_retval = saved_error_retval;

	return ret;
}

struct saved_fd {
	int dup_fd;
	int redir_fd;
};

static bool dup_and_save_fd(int fd, int redir_fd, struct saved_fd *saved) {
	saved->redir_fd = redir_fd;
	saved->dup_fd = -1;

	if (fd == redir_fd) {
		return true;
	}

	saved->dup_fd = dup(redir_fd);
	if (saved->dup_fd < 0) {
		fprintf(stderr, "failed to duplicate file descriptor: %s\n",
			strerror(errno));
		return false;
	}

	if (dup2(fd, redir_fd) < 0) {
		fprintf(stderr, "failed to duplicate file descriptor: %s\n",
			strerror(errno));
		return false;
	}

	return true;
}

static int run_builtin(struct mrsh_context *ctx, struct mrsh_simple_command *sc,
		int argc, char **argv) {
	struct saved_fd fds[sc->io_redirects.len + 1];
	for (size_t i = 0; i < sizeof(fds) / sizeof(fds[0]); ++i) {
		fds[i].dup_fd = fds[i].redir_fd = -1;
	}

	for (size_t i = 0; i < sc->io_redirects.len; ++i) {
		struct mrsh_io_redirect *redir = sc->io_redirects.data[i];
		struct saved_fd *saved = &fds[i];

		int redir_fd;
		int fd = process_redir(redir, &redir_fd);
		if (fd < 0) {
			return TASK_STATUS_ERROR;
		}

		if (!dup_and_save_fd(fd, redir_fd, saved)) {
			return TASK_STATUS_ERROR;
		}
	}

	int ret = mrsh_run_builtin(ctx->state, argc, argv);

	fflush(stdout);
	fflush(stderr);

	for (size_t i = 0; i < sizeof(fds) / sizeof(fds[0]); ++i) {
		if (fds[i].dup_fd < 0) {
			continue;
		}

		if (dup2(fds[i].dup_fd, fds[i].redir_fd) < 0) {
			fprintf(stderr, "failed to duplicate file descriptor: %s\n",
				strerror(errno));
			return TASK_STATUS_ERROR;
		}
		close(fds[i].dup_fd);
	}

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

	mrsh_command_destroy(&sc->command);
	for (size_t i = 0; i < args.len; ++i) {
		free(args.data[i]);
	}
	mrsh_array_finish(&args);
	return ret;
}
