/* mrsh/shell/trap.c — WASM stub: no signals */
#include <stdbool.h>
#include "shell/trap.h"

bool set_trap(struct mrsh_state *state, int sig,
		enum mrsh_trap_action action, struct mrsh_program *program) {
	(void)state; (void)sig; (void)action; (void)program;
	return false;
}

bool set_job_control_traps(struct mrsh_state *state, bool enabled) {
	(void)state; (void)enabled;
	return false;
}

bool reset_caught_traps(struct mrsh_state *state) {
	(void)state;
	return true;
}

bool run_pending_traps(struct mrsh_state *state) {
	(void)state;
	return true;
}

bool run_exit_trap(struct mrsh_state *state) {
	(void)state;
	return false;
}
