#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main()
{
	printf("Gonna list the current directory.\n-----------------\n\n");

	int child_pid = fork();

	if(child_pid == 0) {
		// After we fork, we can make the child process transform into
		// ls by using execvp().
		char* args[3] = { "ls", "-al", NULL };
		execvp(args[0], args);

		// if we got here, an error happened.
		perror("couldn't execute program");
		exit(1);
	}
	else {
		// This waitpid() forces the parent to wait (or "block") until
		// the child process terminates.
		waitpid(child_pid, NULL, 0);
		printf("\n-----------------\nDone listing!\n");
	}

	return 0;
}