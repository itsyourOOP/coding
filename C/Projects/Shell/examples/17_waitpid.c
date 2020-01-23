#define _GNU_SOURCE
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char** argv) {
	// Run this program with at least one argument to make it crashy!
	int bad_behavior = argc > 1;

	if(bad_behavior)
		printf("Gonna spawn a crashy process...\n");
	else
		printf("Gonna spawn a well-behaved process! (run with an argument to make it crashy)\n");

	// Here we go...
	int child_pid = fork();

	if(child_pid == 0) {
		// This is the child process's code.
		if(bad_behavior)
			*(char*)NULL = 10; // woops
		else
			return 5;
	}
	else {
		// The second argument of waitpid() lets us see *how* the child terminated.
		int child_status;
		waitpid(child_pid, &child_status, 0);

		// These WIFEXITED, WEXITSTATUS etc. macros are detailed in `man waitpid`.
		if(WIFEXITED(child_status))
			printf("Child exited normally with status %d.\n", WEXITSTATUS(child_status));
		else if(WIFSIGNALED(child_status))
			printf("Child exited due to signal '%s'.\n", strsignal(WTERMSIG(child_status)));
		else
			printf("Child exited for some other reason.\n");
	}

	return 0;
}