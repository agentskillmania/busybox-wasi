/* mrsh/shell/job.c — WASM stub: no job control */
#include <stdbool.h>
#include <mrsh/shell.h>
#include <mrsh/array.h>
#include "shell/job.h"

struct mrsh_job *job_create(struct mrsh_state *state,
		const struct mrsh_node *node) {
	(void)state; (void)node;
	return NULL;
}

void job_destroy(struct mrsh_job *job) {
	(void)job;
}

int job_poll(struct mrsh_job *job) {
	(void)job;
	return 0;
}

int job_wait(struct mrsh_job *job) {
	(void)job;
	return 0;
}

int job_wait_process(struct mrsh_process *proc) {
	(void)proc;
	return 0;
}

bool job_set_foreground(struct mrsh_job *job, bool foreground, bool cont) {
	(void)job; (void)foreground; (void)cont;
	return false;
}

bool init_job_child_process(struct mrsh_state *state) {
	(void)state;
	return false;
}

bool refresh_jobs_status(struct mrsh_state *state) {
	(void)state;
	return false;
}

struct mrsh_job *job_by_id(struct mrsh_state *state,
		const char *id, bool interactive) {
	(void)state; (void)id; (void)interactive;
	return NULL;
}

void job_add_process(struct mrsh_job *job, struct mrsh_process *proc) {
	(void)job; (void)proc;
}

const char *job_state_str(struct mrsh_job *job, bool r) {
	(void)job; (void)r;
	return "Done";
}

void broadcast_sighup_to_jobs(struct mrsh_state *state) {
	(void)state;
}

bool mrsh_set_job_control(struct mrsh_state *state, bool enabled) {
	(void)state; (void)enabled;
	return false;
}
