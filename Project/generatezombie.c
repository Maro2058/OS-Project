#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>


// Creating a zombie process in C
// zombie processes occur when a child process has completed execution but its parent process has not yet read its exit status using wait() or waitpid().
int main() {

    pid_t pid = fork();
    if (pid == 0) {
        // Child process
        exit(0);
    }
    else if (pid > 0) {
        // Parent process
        while(1) {
            sleep(1); 
        }
    }
    else {
        // Fork failed
        fprintf(stderr, "Fork failed!\n");
        return 1;
    }
    return 0;

}