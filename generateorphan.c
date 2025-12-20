#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>


// Creating a orphan process in C
// orphan process: A process whose parent has terminated
int main() {

    pid_t pid = fork();

    // Child process continues to run after parent exits
    if (pid == 0) {
        // Child process
        while(1) {
            sleep(1); 
        }
    }
    else if (pid > 0) {
        // Parent process
        exit(0);
    }
    else {
        // Fork failed
        fprintf(stderr, "Fork failed!\n");
        return 1;
    }
    return 0;

}