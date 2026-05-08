/* mrsh/shell/process.c — WASM stub: no process management */
#include <sys/types.h>
#include "shell/process.h"

struct mrsh_process *process_create(struct mrsh_state *state, pid_t pid) {
	(void)state; (void)pid;
	return NULL;
}

void process_destroy(struct mrsh_process *process) {
	(void)process;
}

int process_poll(struct mrsh_process *process) {
	(void)process;
	return 0;
}

void update_process(struct mrsh_state *state, pid_t pid, int stat) {
	(void)state; (void)pid; (void)stat;
}
